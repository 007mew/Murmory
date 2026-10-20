import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:record/record.dart';
import 'package:murmory/core/audio/audio_recorder_service.dart';
import 'package:murmory/core/audio/models.dart';

class RecordAudioRecorderImpl implements AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final _stateController = StreamController<RecordingState>.broadcast();
  final _levelController = StreamController<AudioLevel>.broadcast();

  RecordingState _state = const RecordingState(status: RecordingStatus.idle);
  String? _currentPath;
  DateTime? _startTime;
  int _accumulatedMs = 0;
  Timer? _levelTimer;

  RecordAudioRecorderImpl() {
    _stateController.add(_state);
  }

  @override
  Stream<RecordingState> get stateStream => _stateController.stream;

  @override
  Stream<AudioLevel> get levelStream => _levelController.stream;

  void _setStatus(RecordingStatus status, {String? error}) {
    _state = _state.copyWith(status: status, error: error);
    _stateController.add(_state);
  }

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<void> requestPermission() async {
    _setStatus(RecordingStatus.permissionRequested);
    final granted = await _recorder.hasPermission();
    _setStatus(granted ? RecordingStatus.idle : RecordingStatus.error, error: granted ? null : 'Permission denied');
  }

  @override
  Future<void> start(String temporaryPath) async {
    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      _setStatus(RecordingStatus.error, error: 'Microphone permission not granted');
      throw Exception('Microphone permission not granted');
    }

    _currentPath = temporaryPath;
    _accumulatedMs = 0;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: temporaryPath,
    );

    _startTime = DateTime.now();
    _setStatus(RecordingStatus.recording);

    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(milliseconds: 60), (_) async {
      if (_state.status == RecordingStatus.recording) {
        final amp = await _recorder.getAmplitude();
        final currentDb = amp.current;
        final normalized = ((currentDb + 60.0) / 60.0).clamp(0.0, 1.0);
        _levelController.add(AudioLevel(normalized));
      }
    });
  }

  @override
  Future<void> pause() async {
    if (_state.status != RecordingStatus.recording) return;
    if (_startTime != null) {
      _accumulatedMs += DateTime.now().difference(_startTime!).inMilliseconds;
    }
    await _recorder.pause();
    _setStatus(RecordingStatus.paused);
  }

  @override
  Future<void> resume() async {
    if (_state.status != RecordingStatus.paused) return;
    _startTime = DateTime.now();
    await _recorder.resume();
    _setStatus(RecordingStatus.recording);
  }

  @override
  Future<RecordedAudio> stop() async {
    _levelTimer?.cancel();
    if (_state.status == RecordingStatus.recording && _startTime != null) {
      _accumulatedMs += DateTime.now().difference(_startTime!).inMilliseconds;
    }
    _setStatus(RecordingStatus.stopping);

    final finalPath = await _recorder.stop();
    final resolvedPath = finalPath ?? _currentPath;

    if (resolvedPath == null) {
      _setStatus(RecordingStatus.error, error: 'Recorder failed to return output path');
      throw Exception('Recorder failed to return output path');
    }

    final file = File(resolvedPath);
    if (!await file.exists()) {
      _setStatus(RecordingStatus.error, error: 'Recorded audio file missing on disk');
      throw Exception('Recorded audio file missing on disk');
    }

    _setStatus(RecordingStatus.saved);

    return RecordedAudio(
      path: resolvedPath,
      durationMs: max(_accumulatedMs, 100),
    );
  }

  @override
  Future<void> cancel() async {
    _levelTimer?.cancel();
    await _recorder.cancel();
    if (_currentPath != null) {
      final f = File(_currentPath!);
      if (await f.exists()) {
        await f.delete();
      }
    }
    _setStatus(RecordingStatus.idle);
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    _recorder.dispose();
    _stateController.close();
    _levelController.close();
  }
}
