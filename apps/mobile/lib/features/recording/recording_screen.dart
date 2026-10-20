import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:murmory/core/audio/models.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/database/database.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _tempFilePath;
  final List<double> _waveformLevels = List.filled(32, 0.05, growable: true);
  StreamSubscription<AudioLevel>? _levelSub;

  @override
  void initState() {
    super.initState();
    unawaited(_startCapture());
  }

  Future<void> _startCapture() async {
    final recorder = ref.read(audioRecorderProvider);

    final hasPerm = await recorder.hasPermission();
    if (!hasPerm) {
      await recorder.requestPermission();
      final granted = await recorder.hasPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to record')),
          );
          context.pop();
        }
        return;
      }
    }

    try {
      final docDir = await getApplicationDocumentsDirectory();
      _tempFilePath = '${docDir.path}/temp_${const Uuid().v4()}.m4a';
      await recorder.start(_tempFilePath!);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });

      _levelSub = recorder.levelStream.listen((lvl) {
        if (mounted) {
          setState(() {
            _waveformLevels.removeAt(0);
            _waveformLevels.add(lvl.amplitude.clamp(0.08, 1.0));
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _stopAndSave() async {
    await HapticFeedback.mediumImpact();
    final recorder = ref.read(audioRecorderProvider);
    final memoriesDao = ref.read(memoriesDaoProvider);

    _timer?.cancel();
    await _levelSub?.cancel();

    try {
      final recordedAudio = await recorder.stop();
      final memoryId = const Uuid().v4();
      final now = DateTime.now();

      await memoriesDao.insertMemory(
        MemoriesCompanion(
          id: drift.Value(memoryId),
          title: drift.Value('Voice Note ${now.toString().substring(0, 16)}'),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
          audioFilePath: drift.Value(recordedAudio.path),
          durationMs: drift.Value(recordedAudio.durationMs),
          transcriptStatus: const drift.Value('queued'),
        ),
      );

      // Trigger offline transcription pipeline in background
      final pipeline = ref.read(transcriptionPipelineProvider);
      unawaited(pipeline.processMemory(memoryId, recordedAudio.path, recordedAudio.durationMs));

      if (mounted) {
        context.pop();
        unawaited(context.push('/memories/$memoryId'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to persist recording: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _cancelRecording() async {
    await HapticFeedback.lightImpact();
    final recorder = ref.read(audioRecorderProvider);
    _timer?.cancel();
    await _levelSub?.cancel();
    await recorder.cancel();
    if (mounted) {
      context.pop();
    }
  }

  String _formatDuration(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _levelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(audioRecorderProvider);

    return Scaffold(
      backgroundColor: MurmoryColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => unawaited(_cancelRecording()),
        ),
        title: const Text('Recording Studio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: MurmoryColors.recordRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(MurmoryRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MurmoryColors.recordRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RECORDING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MurmoryColors.recordRed,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _formatDuration(_elapsedSeconds),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _waveformLevels.map((lvl) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 4,
                    height: (72 * lvl).clamp(4.0, 72.0),
                    decoration: BoxDecoration(
                      color: MurmoryColors.accentLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<RecordingState>(
                    stream: recorder.stateStream,
                    builder: (context, snap) {
                      final isPaused = snap.data?.status == RecordingStatus.paused;
                      return IconButton.filledTonal(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (isPaused) {
                            unawaited(recorder.resume());
                          } else {
                            unawaited(recorder.pause());
                          }
                        },
                        iconSize: 32,
                        icon: Icon(
                          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => unawaited(_stopAndSave()),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => unawaited(_cancelRecording()),
                    iconSize: 32,
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
