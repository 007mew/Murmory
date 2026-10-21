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
  final List<double> _waveformLevels = List.filled(36, 0.08, growable: true);
  StreamSubscription<AudioLevel>? _levelSub;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _liveTranscript = '';
  bool _speechAvailable = false;
  bool _isPaused = false;

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
      } catch (_) {}

      // 2. Start hardware audio capture
      final docDir = await getApplicationDocumentsDirectory();
      _tempFilePath = '${docDir.path}/temp_${const Uuid().v4()}.m4a';
      await recorder.start(_tempFilePath!);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isPaused) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });

      _levelSub = recorder.levelStream.listen((lvl) {
        if (mounted && !_isPaused) {
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

  Future<void> _togglePauseResume() async {
    await HapticFeedback.mediumImpact();
    final recorder = ref.read(audioRecorderProvider);
    if (_isPaused) {
      await recorder.resume();
      setState(() => _isPaused = false);
    } else {
      await recorder.pause();
      setState(() => _isPaused = true);
    }
  }

  Future<void> _stopAndSave() async {
    await HapticFeedback.heavyImpact();
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

      // Trigger automatic transcription in background
      final pipeline = ref.read(transcriptionPipelineProvider);
      unawaited(pipeline.processMemory(
        memoryId,
        recordedAudio.path,
        recordedAudio.durationMs,
      ));

      if (mounted) {
        context.pop();
        unawaited(context.push('/memories/$memoryId'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _cancelRecording() async {
    await HapticFeedback.mediumImpact();
    final recorder = ref.read(audioRecorderProvider);
    _timer?.cancel();
    await _levelSub?.cancel();
    if (_speech.isListening) {
      await _speech.stop();
    }
    await recorder.cancel();
    if (mounted) context.pop();
  }

  String _formatDuration(int seconds) {
    final hrs = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hrs:$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _levelSub?.cancel();
    if (_speech.isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Screen 3: Back button, "Audio", Power/Cancel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: CupertinoIcons.chevron_back,
                    onTap: () => unawaited(_cancelRecording()),
                  ),
                  const Text(
                    'Audio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MurmoryColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  _buildCircleButton(
                    icon: CupertinoIcons.power,
                    onTap: () => unawaited(_cancelRecording()),
                  ),
                ],
              ),
            ),

            // 2. Centered Live Spoken Text Display
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _liveTranscript.isNotEmpty
                          ? _liveTranscript
                          : 'Today we discussed campaign performance, content calendar, and upcoming tasks for the next sprint. The main focus will be improving conversion rate and optimizing landing pages...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        color: _liveTranscript.isNotEmpty
                            ? MurmoryColors.textPrimary
                            : MurmoryColors.textSecondary.withValues(alpha: 0.7),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Centered Royal Blue Waveform Bars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_waveformLevels.length, (i) {
                    final lvl = _waveformLevels[i];
                    final isCenter = (i - _waveformLevels.length / 2).abs() < 12;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 60),
                      margin: const EdgeInsets.symmetric(horizontal: 2.2),
                      width: 4.0,
                      height: (80 * lvl).clamp(8.0, 78.0),
                      decoration: BoxDecoration(
                        color: isCenter
                            ? MurmoryColors.primaryBlue
                            : const Color(0xFFCBD5E1).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // 4. Bottom Audio Control Pod
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row of Controls: Checkmark (Finish), Blue Mic Button, 'X' (Cancel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Finish / Save (Checkmark)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _stopAndSave,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: MurmoryColors.softGrey,
                            shape: BoxShape.circle,
                            border: Border.all(color: MurmoryColors.cardBorder),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.checkmark,
                            color: MurmoryColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),

                      // Center Large Vibrant Royal Blue Mic Button
                      Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _togglePauseResume,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: MurmoryColors.primaryBlue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x553B82F6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isPaused ? CupertinoIcons.play_fill : CupertinoIcons.mic_fill,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Timer: 00:00:26
                          Text(
                            _formatDuration(_elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MurmoryColors.textPrimary,
                              letterSpacing: 0.5,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),

                      // Cancel / Discard ('X')
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => unawaited(_cancelRecording()),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: MurmoryColors.softGrey,
                            shape: BoxShape.circle,
                            border: Border.all(color: MurmoryColors.cardBorder),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: MurmoryColors.iconCoral,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
          boxShadow: MurmoryColors.softShadow,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: MurmoryColors.textPrimary,
          size: 19,
        ),
      ),
    );
  }
}
