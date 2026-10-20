import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/daos/memories_dao.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';
import 'package:murmory/core/database/daos/jobs_dao.dart';
import 'package:murmory/core/audio/audio_recorder_service.dart';
import 'package:murmory/core/audio/record_impl.dart';
import 'package:murmory/core/audio/audio_player_service.dart';
import 'package:murmory/core/files/audio_file_manager.dart';
import 'package:murmory/core/transcription/transcription_service.dart';
import 'package:murmory/core/transcription/transcription_pipeline.dart';
import 'package:murmory/core/retrieval/memory_retrieval_service.dart';
import 'package:murmory/core/export/vault_export_service.dart';
import 'package:murmory/core/tags/tags_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final memoriesDaoProvider = Provider<MemoriesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return MemoriesDao(db);
});

final transcriptDaoProvider = Provider<TranscriptDao>((ref) {
  final db = ref.watch(databaseProvider);
  return TranscriptDao(db);
});

final jobsDaoProvider = Provider<JobsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return JobsDao(db);
});

final audioFileManagerProvider = Provider<AudioFileManager>((ref) {
  return AudioFileManager();
});

final audioRecorderProvider = Provider<AudioRecorderService>((ref) {
  final recorder = RecordAudioRecorderImpl();
  ref.onDispose(() => recorder.dispose());
  return recorder;
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final player = AudioPlayerService();
  ref.onDispose(() => player.dispose());
  return player;
});

final transcriptionServiceProvider = Provider<TranscriptionService>((ref) {
  return LocalOfflineTranscriptionService();
});

final transcriptionPipelineProvider = Provider<TranscriptionPipeline>((ref) {
  return TranscriptionPipeline(
    service: ref.watch(transcriptionServiceProvider),
    memoriesDao: ref.watch(memoriesDaoProvider),
    transcriptDao: ref.watch(transcriptDaoProvider),
    jobsDao: ref.watch(jobsDaoProvider),
  );
});

final memoryRetrievalServiceProvider = Provider<MemoryRetrievalService>((ref) {
  return MemoryRetrievalService(
    memoriesDao: ref.watch(memoriesDaoProvider),
    transcriptDao: ref.watch(transcriptDaoProvider),
  );
});

final vaultExportServiceProvider = Provider<VaultExportService>((ref) {
  return VaultExportService(
    memoriesDao: ref.watch(memoriesDaoProvider),
    transcriptDao: ref.watch(transcriptDaoProvider),
  );
});

final tagsServiceProvider = Provider<TagsService>((ref) {
  final db = ref.watch(databaseProvider);
  return TagsService(db);
});
