class RetrievedCitation {
  final String memoryId;
  final String memoryTitle;
  final String segmentId;
  final int startMs;
  final int endMs;
  final String snippet;
  final DateTime createdAt;

  const RetrievedCitation({
    required this.memoryId,
    required this.memoryTitle,
    required this.segmentId,
    required this.startMs,
    required this.endMs,
    required this.snippet,
    required this.createdAt,
  });

  String get timeFormatted {
    final startSec = (startMs / 1000).round();
    final endSec = (endMs / 1000).round();
    final sMin = (startSec ~/ 60).toString().padLeft(2, '0');
    final sSec = (startSec % 60).toString().padLeft(2, '0');
    final eMin = (endSec ~/ 60).toString().padLeft(2, '0');
    final eSec = (endSec % 60).toString().padLeft(2, '0');
    return '$sMin:$sSec - $eMin:$eSec';
  }
}

class RetrievalResponse {
  final String answer;
  final List<RetrievedCitation> citations;
  final bool hasEvidence;

  const RetrievalResponse({
    required this.answer,
    required this.citations,
    required this.hasEvidence,
  });
}
