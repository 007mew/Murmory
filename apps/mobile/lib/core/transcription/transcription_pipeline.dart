import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/daos/memories_dao.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';
import 'package:murmory/core/database/daos/jobs_dao.dart';
import 'package:murmory/core/transcription/transcription_service.dart';

class TranscriptionPipeline {
  final TranscriptionService _service;
  final MemoriesDao _memoriesDao;
  final TranscriptDao _transcriptDao;
  final JobsDao _jobsDao;

  TranscriptionPipeline({
    required TranscriptionService service,
    required MemoriesDao memoriesDao,
    required TranscriptDao transcriptDao,
    required JobsDao jobsDao,
  })  : _service = service,
        _memoriesDao = memoriesDao,
        _transcriptDao = transcriptDao,
        _jobsDao = jobsDao;

  Future<void> processMemory(
    String memoryId,
    String audioFilePath,
    int durationMs, {
    String? liveTranscript,
  }) async {
    final jobId = const Uuid().v4();
    final now = DateTime.now();

    // 1. Enqueue job
    await _jobsDao.insertJob(
      ProcessingJobsCompanion(
        id: drift.Value(jobId),
        memoryId: drift.Value(memoryId),
        jobType: const drift.Value('transcription'),
        status: const drift.Value('running'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
        scheduledAt: drift.Value(now),
      ),
    );

    await _memoriesDao.updateTranscriptStatus(memoryId, 'processing');

    try {
      // 2. Perform transcription
      final result = await _service.transcribe(
        audioFilePath,
        durationMs: durationMs,
        liveTranscript: liveTranscript,
      );

      // 3. Insert segments
      final segmentCompanions = <TranscriptSegmentsCompanion>[];
      for (int i = 0; i < result.segments.length; i++) {
        final item = result.segments[i];
        segmentCompanions.add(
          TranscriptSegmentsCompanion(
            id: drift.Value(const Uuid().v4()),
            memoryId: drift.Value(memoryId),
            startMs: drift.Value(item.startMs),
            endMs: drift.Value(item.endMs),
            content: drift.Value(item.content),
            confidence: drift.Value(item.confidence),
            sequenceIndex: drift.Value(i),
          ),
        );
      }

      await _transcriptDao.insertSegments(segmentCompanions);

      // 4. Update memory transcript status
      await _memoriesDao.updateTranscriptStatus(memoryId, 'completed');

      // 5. Generate smarter title if title was generic
      final memory = await _memoriesDao.getById(memoryId);
      if (memory != null && memory.title.startsWith('Voice Note')) {
        final words = result.fullText.split(' ').take(5).join(' ');
        if (words.isNotEmpty) {
          final cleanTitle = words.length > 32 ? '${words.substring(0, 32)}...' : words;
          await _memoriesDao.updateTitle(memoryId, cleanTitle);
        }
      }

      // 6. Complete job
      await _jobsDao.updateStatus(jobId, 'done');
    } catch (e) {
      await _jobsDao.updateStatus(jobId, 'failed', errorMessage: e.toString());
      await _memoriesDao.updateTranscriptStatus(memoryId, 'failed');
    }
  }

  /// Backfill transcripts for any memories that are still queued or missing segments
  Future<void> backfillMissingTranscripts() async {
    final memories = await _memoriesDao.watchAll(limit: 100).first;
    for (final memory in memories) {
      final segments = await _transcriptDao.getSegmentsForMemory(memory.id);
      if (segments.isEmpty) {
        unawaited(processMemory(memory.id, memory.audioFilePath, memory.durationMs));
      }
    }
  }
}
