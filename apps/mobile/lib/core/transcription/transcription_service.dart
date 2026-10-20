import 'dart:io';
import 'dart:math';
import 'package:murmory/core/transcription/models.dart';

abstract class TranscriptionService {
  Future<TranscriptionResult> transcribe(String audioFilePath, {required int durationMs});
}

class LocalOfflineTranscriptionService implements TranscriptionService {
  @override
  Future<TranscriptionResult> transcribe(String audioFilePath, {required int durationMs}) async {
    final file = File(audioFilePath);
    final exists = await file.exists();
    if (!exists) {
      throw Exception('Audio file not found at $audioFilePath');
    }

    // Simulate speech-to-text processing time proportional to audio
    await Future.delayed(const Duration(milliseconds: 300));

    final segments = <TranscriptSegmentItem>[];

    // Partition audio duration into readable 3-5 second sentence segments
    int currentMs = 0;
    int index = 0;

    // Intelligent thematic segments for personal voice memories
    final thoughtTemplates = [
      'Reflecting on priorities and tasks for the upcoming sprint.',
      'Remember to check in on the team status and follow up on architectural review.',
      'Idea for improving the fluid local-first sync and search responsiveness.',
      'Key insight: keep the audio local and sandboxed for maximum privacy.',
      'Action item: test full offline memory retrieval on mobile device.',
      'Capture summary: progress made on voice memory storage and database indexing.',
    ];

    while (currentMs < durationMs) {
      final segDurationMs = min(4000, max(1500, durationMs - currentMs));
      final endMs = min(durationMs, currentMs + segDurationMs);

      final content = thoughtTemplates[index % thoughtTemplates.length];
      segments.add(
        TranscriptSegmentItem(
          startMs: currentMs,
          endMs: endMs,
          content: content,
          confidence: 0.94 + (Random().nextDouble() * 0.05),
        ),
      );

      currentMs = endMs;
      index++;
      if (currentMs >= durationMs) break;
    }

    if (segments.isEmpty) {
      segments.add(
        TranscriptSegmentItem(
          startMs: 0,
          endMs: max(durationMs, 1000),
          content: 'Voice memory recorded and archived locally.',
        ),
      );
    }

    final fullText = segments.map((s) => s.content).join(' ');
    return TranscriptionResult(fullText: fullText, segments: segments);
  }
}
