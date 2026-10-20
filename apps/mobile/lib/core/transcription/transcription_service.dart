import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murmory/core/transcription/models.dart';

abstract class TranscriptionService {
  Future<TranscriptionResult> transcribe(
    String audioFilePath, {
    required int durationMs,
    String? liveTranscript,
  });
}

class HybridTranscriptionService implements TranscriptionService {
  @override
  Future<TranscriptionResult> transcribe(
    String audioFilePath, {
    required int durationMs,
    String? liveTranscript,
  }) async {
    final file = File(audioFilePath);
    final exists = await file.exists();
    if (!exists) {
      throw Exception('Audio file not found at $audioFilePath');
    }

    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groq_api_key')?.trim();
    final openaiApiKey = prefs.getString('openai_api_key')?.trim();

    // 1. If Groq API key is configured, use Whisper Large v3 (ultra-fast & accurate)
    if (groqApiKey != null && groqApiKey.isNotEmpty) {
      try {
        final result = await _transcribeWithWhisperApi(
          audioFile: file,
          durationMs: durationMs,
          apiUrl: 'https://api.groq.com/openai/v1/audio/transcriptions',
          apiKey: groqApiKey,
          model: 'whisper-large-v3',
        );
        if (result != null && result.segments.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // Fall back to live or local transcript on error
      }
    }

    // 2. If OpenAI API key is configured, use OpenAI Whisper
    if (openaiApiKey != null && openaiApiKey.isNotEmpty) {
      try {
        final result = await _transcribeWithWhisperApi(
          audioFile: file,
          durationMs: durationMs,
          apiUrl: 'https://api.openai.com/v1/audio/transcriptions',
          apiKey: openaiApiKey,
          model: 'whisper-1',
        );
        if (result != null && result.segments.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // Fall back
      }
    }

    // 3. If live speech-to-text words were captured during recording
    if (liveTranscript != null && liveTranscript.trim().isNotEmpty) {
      return _buildSegmentsFromText(liveTranscript.trim(), durationMs);
    }

    // 4. Clean local fallback: NO canned fake thoughts. Honest status.
    final cleanDurationSec = (durationMs / 1000).round();
    final fallbackText = cleanDurationSec < 2
        ? 'Brief voice capture recorded.'
        : 'Voice note recorded ($cleanDurationSec s). Tap edit to add transcript or enter a Whisper API key in Settings.';

    return TranscriptionResult(
      fullText: fallbackText,
      segments: [
        TranscriptSegmentItem(
          startMs: 0,
          endMs: max(durationMs, 1000),
          content: fallbackText,
          confidence: 0.90,
        ),
      ],
    );
  }

  /// Partition recognized real words into natural sentence blocks with timestamps
  TranscriptionResult _buildSegmentsFromText(String text, int totalDurationMs) {
    // Split on punctuation or chunks of 6-10 words
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) {
      return TranscriptionResult(
        fullText: text,
        segments: [
          TranscriptSegmentItem(
            startMs: 0,
            endMs: max(totalDurationMs, 1000),
            content: text,
          ),
        ],
      );
    }

    final segments = <TranscriptSegmentItem>[];
    const chunkSize = 8;
    final totalChunks = (words.length / chunkSize).ceil();
    final chunkMs = totalChunks > 0 ? (totalDurationMs / totalChunks).round() : totalDurationMs;

    for (int i = 0; i < words.length; i += chunkSize) {
      final chunkWords = words.sublist(i, min(i + chunkSize, words.length));
      final chunkText = chunkWords.join(' ');
      final chunkIndex = i ~/ chunkSize;
      final startMs = chunkIndex * chunkMs;
      final endMs = min(totalDurationMs, (chunkIndex + 1) * chunkMs);

      segments.add(
        TranscriptSegmentItem(
          startMs: startMs,
          endMs: max(endMs, startMs + 800),
          content: chunkText,
          confidence: 0.95,
        ),
      );
    }

    return TranscriptionResult(fullText: text, segments: segments);
  }

  /// Calls OpenAI-compatible Whisper transcription API (Groq or OpenAI)
  Future<TranscriptionResult?> _transcribeWithWhisperApi({
    required File audioFile,
    required int durationMs,
    required String apiUrl,
    required String apiKey,
    required String model,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = model
      ..fields['response_format'] = 'verbose_json'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final fullText = (data['text'] as String? ?? '').trim();
    final rawSegments = data['segments'] as List<dynamic>? ?? [];

    final segments = <TranscriptSegmentItem>[];
    for (final seg in rawSegments) {
      final start = ((seg['start'] as num?)?.toDouble() ?? 0.0) * 1000;
      final end = ((seg['end'] as num?)?.toDouble() ?? 0.0) * 1000;
      final segText = (seg['text'] as String? ?? '').trim();

      if (segText.isNotEmpty) {
        segments.add(
          TranscriptSegmentItem(
            startMs: start.round(),
            endMs: max(end.round(), start.round() + 500),
            content: segText,
            confidence: 0.98,
          ),
        );
      }
    }

    if (segments.isEmpty && fullText.isNotEmpty) {
      segments.add(
        TranscriptSegmentItem(
          startMs: 0,
          endMs: max(durationMs, 1000),
          content: fullText,
        ),
      );
    }

    return TranscriptionResult(
      fullText: fullText.isNotEmpty ? fullText : 'No speech detected.',
      segments: segments,
    );
  }
}
