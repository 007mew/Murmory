import 'package:intl/intl.dart';
import 'package:murmory/core/database/daos/memories_dao.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';
import 'package:murmory/core/retrieval/retrieval_models.dart';

class MemoryRetrievalService {
  final MemoriesDao _memoriesDao;
  final TranscriptDao _transcriptDao;

  MemoryRetrievalService({
    required MemoriesDao memoriesDao,
    required TranscriptDao transcriptDao,
  })  : _memoriesDao = memoriesDao,
        _transcriptDao = transcriptDao;

  Future<RetrievalResponse> ask(String question) async {
    final query = question.trim().toLowerCase();
    if (query.isEmpty) {
      return const RetrievalResponse(
        answer: 'Please enter a question to ask your memories.',
        citations: [],
        hasEvidence: false,
      );
    }

    final allMemories = await _memoriesDao.watchAll(limit: 50).first;
    if (allMemories.isEmpty) {
      return const RetrievalResponse(
        answer: 'You have not recorded any voice memories yet. Tap the microphone on the Home screen to capture your first memory!',
        citations: [],
        hasEvidence: false,
      );
    }

    // Stop words to filter out
    const stopWords = {
      'what', 'did', 'i', 'say', 'about', 'the', 'a', 'an', 'in', 'on', 'at',
      'to', 'for', 'of', 'and', 'or', 'is', 'are', 'was', 'were', 'my', 'me',
      'tell', 'summarize', 'show', 'any', 'all', 'do', 'have', 'had', 'find'
    };

    final queryTokens = query
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty && !stopWords.contains(t))
        .toSet();

    final isTemporalQuery = query.contains('today') ||
        query.contains('recent') ||
        query.contains('latest') ||
        query.contains('now');

    final scoredCitations = <_ScoredCitation>[];

    for (final memory in allMemories) {
      final segments = await _transcriptDao.getSegmentsForMemory(memory.id);
      final memoryDate = memory.createdAt;
      final isRecent = DateTime.now().difference(memoryDate).inHours < 24;

      for (final segment in segments) {
        final text = segment.content.toLowerCase();
        final title = memory.title.toLowerCase();

        double score = 0.0;

        // Exact phrase match
        if (text.contains(query)) {
          score += 10.0;
        }

        // Token match
        for (final token in queryTokens) {
          if (text.contains(token)) {
            score += 3.0;
          }
          if (title.contains(token)) {
            score += 2.0;
          }
        }

        // Temporal bonus
        if (isTemporalQuery && isRecent) {
          score += 4.0;
        }

        if (score > 0) {
          scoredCitations.add(
            _ScoredCitation(
              citation: RetrievedCitation(
                memoryId: memory.id,
                memoryTitle: memory.title,
                segmentId: segment.id,
                startMs: segment.startMs,
                endMs: segment.endMs,
                snippet: segment.content,
                createdAt: memory.createdAt,
              ),
              score: score,
            ),
          );
        }
      }
    }

    // Fallback: If query tokens were generic or user asked for a summary of recent notes
    if (scoredCitations.isEmpty && (isTemporalQuery || queryTokens.isEmpty)) {
      final recent = allMemories.take(3);
      for (final memory in recent) {
        final segments = await _transcriptDao.getSegmentsForMemory(memory.id);
        if (segments.isNotEmpty) {
          final firstSeg = segments.first;
          scoredCitations.add(
            _ScoredCitation(
              citation: RetrievedCitation(
                memoryId: memory.id,
                memoryTitle: memory.title,
                segmentId: firstSeg.id,
                startMs: firstSeg.startMs,
                endMs: firstSeg.endMs,
                snippet: firstSeg.content,
                createdAt: memory.createdAt,
              ),
              score: 1.0,
            ),
          );
        }
      }
    }

    if (scoredCitations.isEmpty) {
      return RetrievalResponse(
        answer: 'No matching voice memories were found for "$question". Your thoughts are searched strictly offline from your local vault. Try asking about a topic you recorded, or record a new thought with the microphone.',
        citations: const [],
        hasEvidence: false,
      );
    }

    // Sort by score descending
    scoredCitations.sort((a, b) => b.score.compareTo(a.score));

    final topCitations = scoredCitations.take(3).map((c) => c.citation).toList();

    // Synthesize grounded answer
    final buffer = StringBuffer();
    if (topCitations.length == 1) {
      final c = topCitations.first;
      final dateStr = DateFormat('MMM d, h:mm a').format(c.createdAt);
      buffer.write('In your recording from $dateStr ("${c.memoryTitle}"), you noted:\n\n');
      buffer.write('"${c.snippet}"');
    } else {
      buffer.write('Found ${topCitations.length} relevant memories across your vault:\n\n');
      for (int i = 0; i < topCitations.length; i++) {
        final c = topCitations[i];
        final dateStr = DateFormat('MMM d').format(c.createdAt);
        buffer.write('${i + 1}. From "${c.memoryTitle}" ($dateStr): "${c.snippet}"\n\n');
      }
    }

    return RetrievalResponse(
      answer: buffer.toString().trim(),
      citations: topCitations,
      hasEvidence: true,
    );
  }
}

class _ScoredCitation {
  final RetrievedCitation citation;
  final double score;

  const _ScoredCitation({required this.citation, required this.score});
}
