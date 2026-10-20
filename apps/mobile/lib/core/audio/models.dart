enum RecordingStatus {
  idle,
  permissionRequested,
  recording,
  paused,
  stopping,
  saved,
  error,
}

class RecordingState {
  const RecordingState({
    required this.status,
    this.durationMs = 0,
    this.error,
  });

  final RecordingStatus status;
  final int durationMs;
  final String? error;

  RecordingState copyWith({
    RecordingStatus? status,
    int? durationMs,
    String? error,
  }) {
    return RecordingState(
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
    );
  }

  bool get isActive =>
      status == RecordingStatus.recording || status == RecordingStatus.paused;
}

class AudioLevel {
  const AudioLevel(this.amplitude);
  final double amplitude; // 0.0 to 1.0 normalized
}

class RecordedAudio {
  const RecordedAudio({
    required this.path,
    required this.durationMs,
  });

  final String path;
  final int durationMs;
}

enum PlaybackStatus { idle, loading, playing, paused, completed, error }

class PlaybackState {
  const PlaybackState({
    required this.status,
    this.positionMs = 0,
    this.durationMs = 0,
    this.error,
  });

  final PlaybackStatus status;
  final int positionMs;
  final int durationMs;
  final String? error;

  bool get isPlaying => status == PlaybackStatus.playing;

  double get progress {
    if (durationMs == 0) return 0;
    return (positionMs / durationMs).clamp(0.0, 1.0);
  }

  PlaybackState copyWith({
    PlaybackStatus? status,
    int? positionMs,
    int? durationMs,
    String? error,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
    );
  }
}
