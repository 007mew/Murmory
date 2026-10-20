import 'package:murmory/core/audio/models.dart';

abstract interface class AudioRecorderService {
  Future<void> requestPermission();
  Future<bool> hasPermission();
  Future<void> start(String temporaryPath);
  Future<void> pause();
  Future<void> resume();
  Future<RecordedAudio> stop();
  Future<void> cancel();
  Stream<RecordingState> get stateStream;
  Stream<AudioLevel> get levelStream;
  void dispose();
}
