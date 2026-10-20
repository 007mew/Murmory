import 'package:drift/drift.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/tables/transcript_segments_table.dart';

part 'transcript_dao.g.dart';

@DriftAccessor(tables: [TranscriptSegments])
class TranscriptDao extends DatabaseAccessor<AppDatabase>
    with _$TranscriptDaoMixin {
  TranscriptDao(super.db);

  /// Get all segments for a memory, ordered by sequence
  Future<List<TranscriptSegment>> getSegmentsForMemory(String memoryId) {
    return (select(transcriptSegments)
          ..where((t) => t.memoryId.equals(memoryId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)]))
        .get();
  }

  /// Watch all segments for a memory
  Stream<List<TranscriptSegment>> watchSegmentsForMemory(String memoryId) {
    return (select(transcriptSegments)
          ..where((t) => t.memoryId.equals(memoryId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)]))
        .watch();
  }

  /// Insert a batch of segments
  Future<void> insertSegments(
      List<TranscriptSegmentsCompanion> segments) async {
    await batch((b) {
      b.insertAll(transcriptSegments, segments,
          mode: InsertMode.insertOrReplace);
    });
  }

  /// Delete all segments for a memory
  Future<int> deleteForMemory(String memoryId) {
    return (delete(transcriptSegments)
          ..where((t) => t.memoryId.equals(memoryId)))
        .go();
  }

  /// Update segment text
  Future<void> updateSegmentContent(String segmentId, String newContent) async {
    await (update(transcriptSegments)..where((t) => t.id.equals(segmentId))).write(
      TranscriptSegmentsCompanion(
        content: Value(newContent),
      ),
    );
  }

  /// Get concatenated full text for a memory
  Future<String> getFullTranscript(String memoryId) async {
    final segments = await getSegmentsForMemory(memoryId);
    return segments.map((s) => s.content).join(' ');
  }

  /// FTS5 full-text search across all transcripts
  /// Returns rows of (memory_id, segment_id, snippet)
  Future<List<FtsSearchResult>> searchTranscripts(String query) async {
    // Sanitize query for FTS5
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final sanitized = trimmed.replaceAll('"', '""');
    final ftsQuery = '$sanitized*';

    try {
      final results = await db.customSelect(
        '''
        SELECT
          memory_id,
          segment_id,
          snippet(transcript_fts, 2, '<b>', '</b>', '...', 20) AS snippet
        FROM transcript_fts
        WHERE transcript_fts MATCH ?
        ORDER BY rank
        LIMIT 50
        ''',
        variables: [Variable.withString(ftsQuery)],
      ).get();

      return results.map((row) {
        return FtsSearchResult(
          memoryId: row.read<String>('memory_id'),
          segmentId: row.read<String>('segment_id'),
          snippet: row.read<String>('snippet'),
        );
      }).toList();
    } catch (_) {
      // Fallback to LIKE query if FTS expression has syntax error
      final likeQuery = '%$trimmed%';
      final segments = await (select(transcriptSegments)
            ..where((t) => t.content.like(likeQuery))
            ..limit(50))
          .get();

      return segments.map((s) {
        return FtsSearchResult(
          memoryId: s.memoryId,
          segmentId: s.id,
          snippet: s.content,
        );
      }).toList();
    }
  }
}

class FtsSearchResult {
  const FtsSearchResult({
    required this.memoryId,
    required this.segmentId,
    required this.snippet,
  });

  final String memoryId;
  final String segmentId;
  final String snippet;
}
