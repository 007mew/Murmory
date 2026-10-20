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
    final googleApiKey = prefs.getString('google_api_key')?.trim();
    final groqApiKey = prefs.getString('groq_api_key')?.trim();
    final openaiApiKey = prefs.getString('openai_api_key')?.trim();

    // 1. Google Speech-to-Text / Gemini Multimodal API (supports M4A directly, multilingual)
    if (googleApiKey != null && googleApiKey.isNotEmpty) {
      try {
        final result = await _transcribeWithGoogleSpeechApi(
          audioFile: file,
          durationMs: durationMs,
          apiKey: googleApiKey,
        );
        if (result != null && result.segments.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // Fall back to next provider
      }
    }

    // 2. Groq Whisper Large v3 (free, ultra-fast <1s)
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
        // Fall back
      }
    }

    // 3. OpenAI Whisper
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

    // 4. If live speech-to-text words were captured during recording
    if (liveTranscript != null && liveTranscript.trim().isNotEmpty) {
      return _buildSegmentsFromText(liveTranscript.trim(), durationMs);
    }

    // 5. Clean local fallback: honest status
    final cleanDurationSec = (durationMs / 1000).round();
    final fallbackText = cleanDurationSec < 2
        ? 'Brief voice capture recorded.'
        : 'Voice note recorded ($cleanDurationSec s). Tap edit to add transcript or configure Google / Groq Speech in Settings.';

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

  /// Transcribes using Google Speech-to-Text / Gemini Audio API
  Future<TranscriptionResult?> _transcribeWithGoogleSpeechApi({
    required File audioFile,
    required int durationMs,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final bytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": "Transcribe this audio recording accurately. Break the transcription into timestamped sentence segments. Output MUST be ONLY a valid JSON array matching this format: [{\"startMs\": 0, \"endMs\": 3000, \"content\": \"Spoken sentence\"}]. Return ONLY the JSON array without markdown formatting or code blocks."
            },
            {
              "inline_data": {
                "mime_type": "audio/mp4",
                "data": base64Audio
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1
      }
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;

    final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;

    var rawText = (parts[0]['text'] as String? ?? '').trim();
    if (rawText.startsWith('```json')) {
      rawText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
    } else if (rawText.startsWith('```')) {
      rawText = rawText.replaceAll('```', '').trim();
    }

    try {
      final parsedJson = jsonDecode(rawText) as List<dynamic>;
      final segments = <TranscriptSegmentItem>[];
      for (final item in parsedJson) {
        if (item is Map<String, dynamic>) {
          final start = (item['startMs'] as num?)?.toInt() ?? 0;
          final end = (item['endMs'] as num?)?.toInt() ?? max(durationMs, 1000);
          final content = (item['content'] as String? ?? '').trim();
          if (content.isNotEmpty) {
            segments.add(TranscriptSegmentItem(
              startMs: start,
              endMs: max(end, start + 500),
              content: content,
              confidence: 0.99,
            ));
          }
        }
      }

      if (segments.isNotEmpty) {
        final fullText = segments.map((s) => s.content).join(' ');
        return TranscriptionResult(fullText: fullText, segments: segments);
      }
    } catch (_) {
      if (rawText.isNotEmpty) {
        return _buildSegmentsFromText(rawText, durationMs);
      }
    }

    return null;
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
