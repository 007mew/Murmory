import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:murmory/core/audio/models.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _liveTranscript = '';
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initSpeechAndStartCapture());
  }

  Future<void> _initSpeechAndStartCapture() async {
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
      // 1. Initialize Speech To Text for live word capture
      try {
        _speechAvailable = await _speech.initialize(
          onError: (_) {},
          onStatus: (_) {},
        );
        if (_speechAvailable) {
          unawaited(_speech.listen(
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _liveTranscript = result.recognizedWords;
                });
              }
            },
            listenOptions: stt.SpeechListenOptions(
              listenMode: stt.ListenMode.dictation,
              partialResults: true,
            ),
          ));
        }
      } catch (_) {
        // SpeechRecognizer might not support concurrent mic on older hardware
      }

      // 2. Start hardware audio capture
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
    if (_speech.isListening) {
      await _speech.stop();
    }

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

      // Trigger transcription pipeline in background with live captured words
      final pipeline = ref.read(transcriptionPipelineProvider);
      unawaited(pipeline.processMemory(
        memoryId,
        recordedAudio.path,
        recordedAudio.durationMs,
        liveTranscript: _liveTranscript.trim().isNotEmpty ? _liveTranscript : null,
      ));

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
    if (_speech.isListening) {
      await _speech.cancel();
    }
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
    if (_speech.isListening) {
      _speech.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(audioRecorderProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient liquid glow orbs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // iOS-style top navigation bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white60, size: 30),
                        tooltip: 'Cancel',
                        onPressed: () => unawaited(_cancelRecording()),
                      ),
                      const Text(
                        'Voice Capture',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48), // balance leading
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Pulsing Recording Status Pill (iOS style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: MurmoryColors.recordRed.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: MurmoryColors.recordRed.withValues(alpha: 0.35),
                      width: 1.1,
                    ),
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
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Timer Display (iOS Monospace)
                Text(
                  _formatDuration(_elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),

                const SizedBox(height: 32),

                // Liquid Glass Waveform Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LiquidGlass(
                    blur: 16,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: SizedBox(
                      height: 64,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _waveformLevels.map((lvl) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 60),
                            margin: const EdgeInsets.symmetric(horizontal: 2.2),
                            width: 3.5,
                            height: (64 * lvl).clamp(5.0, 64.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFA78BFA), Color(0xFF6366F1)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Live Real-Time Speech Recognition Pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LiquidGlass(
                    blur: 14,
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.waveform_path_badge_plus,
                          color: MurmoryColors.accentLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _liveTranscript.isNotEmpty
                                ? _liveTranscript
                                : (_speechAvailable
                                    ? 'Listening for speech...'
                                    : 'Recording local audio stream...'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: _liveTranscript.isNotEmpty
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: _liveTranscript.isNotEmpty
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // iOS-Style Control Dock
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Trash / Cancel
                      LiquidGlass(
                        blur: 12,
                        borderRadius: 30,
                        padding: EdgeInsets.zero,
                        onTap: () => unawaited(_cancelRecording()),
                        child: Container(
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.trash,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ),

                      // Stop & Save Checkmark (Main iOS Liquid Button)
                      GestureDetector(
                        onTap: () => unawaited(_stopAndSave()),
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.55),
                                blurRadius: 28,
                                spreadRadius: 3,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),

                      // Pause / Resume StreamBuilder
                      StreamBuilder<RecordingState>(
                        stream: recorder.stateStream,
                        builder: (context, snap) {
                          final isPaused = snap.data?.status == RecordingStatus.paused;
                          return LiquidGlass(
                            blur: 12,
                            borderRadius: 30,
                            padding: EdgeInsets.zero,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (isPaused) {
                                unawaited(recorder.resume());
                              } else {
                                unawaited(recorder.pause());
                              }
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              alignment: Alignment.center,
                              child: Icon(
                                isPaused ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
