class TranscriptSegmentItem {
  final int startMs;
  final int endMs;
  final String content;
  final double confidence;

  const TranscriptSegmentItem({
    required this.startMs,
    required this.endMs,
    required this.content,
    this.confidence = 0.95,
  });
}

class TranscriptionResult {
  final String fullText;
  final List<TranscriptSegmentItem> segments;

  const TranscriptionResult({
    required this.fullText,
    required this.segments,
  });
}
