import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/tags/tags_service.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  late final AudioPlayer _player;
  late final Stream<Memory?> _memoryStream;
  late final Stream<List<TagItem>> _tagsStream;
  late final Stream<List<TranscriptSegment>> _transcriptStream;

  bool _isPlaying = false;
  bool _isScrubbing = false;
  double _dragProgress = 0.0;
  Duration _currentPos = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _memoryStream = ref.read(memoriesDaoProvider).watchById(widget.id);
    _tagsStream = ref.read(tagsServiceProvider).watchTagsForMemory(widget.id);
    _transcriptStream = ref.read(transcriptDaoProvider).watchSegmentsForMemory(widget.id);
    _initAudio();
  }

  Future<void> _initAudio() async {
    final memoriesDao = ref.read(memoriesDaoProvider);
    final memory = await memoriesDao.getById(widget.id);
    if (memory != null && memory.audioFilePath.isNotEmpty) {
      final file = File(memory.audioFilePath);
      if (await file.exists()) {
        try {
          if (memory.durationMs > 0) {
            _totalDuration = Duration(milliseconds: memory.durationMs);
          }
          await _player.setFilePath(memory.audioFilePath);

          _player.playerStateStream.listen((state) {
            if (!mounted) return;
            final isCompleted = state.processingState == ProcessingState.completed;
            setState(() {
              _isPlaying = state.playing && !isCompleted;
              if (isCompleted) {
                _currentPos = _totalDuration;
              }
            });
          });

          _player.positionStream.listen((pos) {
            if (!mounted) return;
            if (!_isScrubbing) {
              setState(() => _currentPos = pos);
            }
          });

          _player.durationStream.listen((dur) {
            if (!mounted) return;
            if (dur != null && dur > Duration.zero) {
              setState(() => _totalDuration = dur);
            }
          });
        } catch (_) {}
      }
    }
  }

  Future<void> _togglePlay() async {
    await HapticFeedback.lightImpact();
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed ||
          _currentPos >= _totalDuration - const Duration(milliseconds: 250)) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    await HapticFeedback.selectionClick();
    final target = _currentPos + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _totalDuration ? _totalDuration : target);
    await _player.seek(clamped);
    if (mounted) setState(() => _currentPos = clamped);
  }

  Future<void> _transcribeWithGoogleSpeech(Memory memory) async {
    final prefs = await SharedPreferences.getInstance();
    final googleKey = prefs.getString('google_api_key')?.trim();

    if (!mounted) return;

    if (googleKey == null || googleKey.isEmpty) {
      unawaited(showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Google API Key Required'),
          content: const Text(
            'Please enter your free Google Cloud or Gemini API key in Settings -> Transcription Engine to enable Google Speech-to-Text.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/settings');
              },
            ),
          ],
        ),
      ));
      return;
    }

    setState(() => _isTranscribing = true);

    try {
      final pipeline = ref.read(transcriptionPipelineProvider);
      await pipeline.processMemory(memory.id, memory.audioFilePath, memory.durationMs);

      if (mounted) {
        setState(() => _isTranscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transcription complete via Google Speech.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranscribing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Speech transcription failed: $e')),
        );
      }
    }
  }

  Future<void> _editTitle(Memory memory) async {
    final controller = TextEditingController(text: memory.title);
    final updated = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Edit Title'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Enter memory title',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty && mounted) {
      await ref.read(memoriesDaoProvider).updateTitle(memory.id, updated);
    }
  }

  Future<void> _editSegment(TranscriptSegment segment) async {
    final controller = TextEditingController(text: segment.content);
    final updated = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Edit Segment'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            placeholder: 'Correct spoken text',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty && mounted) {
      await ref.read(transcriptDaoProvider).updateSegmentContent(segment.id, updated);
    }
  }

  Future<void> _showAddTagDialog(String memoryId) async {
    final tagsService = ref.read(tagsServiceProvider);
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return LiquidGlass(
          blur: 24,
          borderRadius: 28,
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Tag',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TagsService.defaultTags.map((tag) {
                  return ActionChip(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    label: Text(tag, style: const TextStyle(color: Colors.white)),
                    onPressed: () async {
                      await tagsService.addTagToMemory(memoryId, tag);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                      placeholder: 'New custom tag (e.g. #strategy)',
                      placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () async {
                      final raw = controller.text.trim();
                      if (raw.isNotEmpty) {
                        final tagName = raw.startsWith('#') ? raw : '#$raw';
                        await tagsService.addTagToMemory(memoryId, tagName);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMemory(Memory memory) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text('This will delete the local audio recording and its transcript permanently.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(memoriesDaoProvider).deleteById(memory.id);
      if (mounted) context.pop();
    }
  }

  String _formatDuration(Duration d) {
    final totalSecs = d.inSeconds;
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoriesDao = ref.watch(memoriesDaoProvider);
    final currentMs = _currentPos.inMilliseconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: StreamBuilder<Memory?>(
              stream: _memoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator(color: Colors.white));
                }

                final memory = snapshot.data;
                if (memory == null) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator(color: Colors.white));
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_triangle, size: 48, color: Colors.white54),
                        const SizedBox(height: 12),
                        const Text('Memory not found', style: TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 12),
                        CupertinoButton(
                          child: const Text('Go Back'),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  );
                }

                final dateFormatted = DateFormat('MMMM d, yyyy • h:mm a').format(memory.createdAt);

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // iOS Navigation Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LiquidGlass(
                              borderRadius: 22,
                              padding: EdgeInsets.zero,
                              onTap: () => context.pop(),
                              child: Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 22),
                              ),
                            ),
                            const Text(
                              'Memory Detail',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Row(
                              children: [
                                LiquidGlass(
                                  borderRadius: 22,
                                  padding: EdgeInsets.zero,
                                  onTap: () async {
                                    await HapticFeedback.lightImpact();
                                    await memoriesDao.toggleFavorite(memory.id, !memory.isFavorite);
                                  },
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      memory.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                      color: memory.isFavorite ? Colors.redAccent : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                LiquidGlass(
                                  borderRadius: 22,
                                  padding: EdgeInsets.zero,
                                  onTap: () => _deleteMemory(memory),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    alignment: Alignment.center,
                                    child: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Edit Button
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    memory.title,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(CupertinoIcons.pencil, color: MurmoryColors.accentLight, size: 22),
                                  tooltip: 'Edit Title',
                                  onPressed: () => _editTitle(memory),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormatted,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tags Section
                            StreamBuilder<List<TagItem>>(
                              stream: _tagsStream,
                              builder: (context, snap) {
                                final tags = snap.data ?? [];
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...tags.map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: MurmoryColors.accent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: MurmoryColors.accent.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          tag.name,
                                          style: const TextStyle(
                                            color: MurmoryColors.accentLight,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showAddTagDialog(memory.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(CupertinoIcons.plus, size: 12, color: Colors.white70),
                                            SizedBox(width: 4),
                                            Text(
                                              'Add Tag',
                                              style: TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Bug-Free Smooth iOS Audio Player Card
                            LiquidGlass(
                              borderRadius: 24,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_isScrubbing
                                            ? Duration(milliseconds: (_dragProgress * _totalDuration.inMilliseconds).round())
                                            : _currentPos),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_totalDuration),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withValues(alpha: 0.45),
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                      activeTrackColor: MurmoryColors.accent,
                                      inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                                      thumbColor: Colors.white,
                                      trackHeight: 3.5,
                                    ),
                                    child: Slider(
                                      value: _isScrubbing
                                          ? _dragProgress
                                          : (_totalDuration.inMilliseconds > 0
                                              ? (_currentPos.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
                                              : 0.0),
                                      onChangeStart: (val) {
                                        setState(() {
                                          _isScrubbing = true;
                                          _dragProgress = val;
                                        });
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          _dragProgress = val;
                                        });
                                      },
                                      onChangeEnd: (val) async {
                                        final target = Duration(milliseconds: (val * _totalDuration.inMilliseconds).round());
                                        await _player.seek(target);
                                        if (mounted) {
                                          setState(() {
                                            _isScrubbing = false;
                                            _currentPos = target;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(CupertinoIcons.gobackward_10, color: Colors.white70),
                                        iconSize: 26,
                                        onPressed: () => _seekRelative(-10),
                                      ),
                                      const SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: _togglePlay,
                                        child: Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                                                blurRadius: 20,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _isPlaying ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      IconButton(
                                        icon: const Icon(CupertinoIcons.goforward_10, color: Colors.white70),
                                        iconSize: 26,
                                        onPressed: () => _seekRelative(10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Google Speech-to-Text Button
                            LiquidGlass(
                              borderRadius: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(CupertinoIcons.sparkles, color: Colors.blueAccent, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Google Speech-to-Text',
                                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                                        ),
                                        Text(
                                          'Accurate speech transcription with timestamps',
                                          style: TextStyle(fontSize: 11, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    color: Colors.blueAccent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                    onPressed: _isTranscribing ? null : () => _transcribeWithGoogleSpeech(memory),
                                    child: _isTranscribing
                                        ? const CupertinoActivityIndicator(color: Colors.white)
                                        : const Text('Transcribe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Transcript Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transcript',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Tap sentence to jump',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Transcript Segments List
                            StreamBuilder<List<TranscriptSegment>>(
                              stream: _transcriptStream,
                              builder: (context, snap) {
                                final segments = snap.data ?? [];

                                if (segments.isEmpty) {
                                  return LiquidGlass(
                                    borderRadius: 20,
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        const Icon(CupertinoIcons.waveform, size: 40, color: MurmoryColors.accentLight),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No transcript generated yet',
                                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tap the button above to transcribe with Google Speech-to-Text.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55)),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: segments.length,
                                  separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                                  itemBuilder: (ctx, i) {
                                    final seg = segments[i];
                                    final isCurrentlyPlaying = currentMs >= seg.startMs && currentMs < seg.endMs;
                                    final startSec = (seg.startMs / 1000).round();
                                    final minStr = (startSec ~/ 60).toString().padLeft(2, '0');
                                    final secStr = (startSec % 60).toString().padLeft(2, '0');

                                    return LiquidGlass(
                                      borderRadius: 16,
                                      padding: const EdgeInsets.all(14),
                                      opacity: isCurrentlyPlaying ? 0.20 : 0.05,
                                      borderOpacity: isCurrentlyPlaying ? 0.45 : 0.10,
                                      tintColor: isCurrentlyPlaying ? MurmoryColors.accent : Colors.white,
                                      onTap: () async {
                                        await HapticFeedback.selectionClick();
                                        await _player.seek(Duration(milliseconds: seg.startMs));
                                        if (!_isPlaying) await _player.play();
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isCurrentlyPlaying
                                                  ? MurmoryColors.accent
                                                  : Colors.white.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$minStr:$secStr',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isCurrentlyPlaying ? Colors.white : Colors.white70,
                                                fontFeatures: const [FontFeature.tabularFigures()],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              seg.content,
                                              style: TextStyle(
                                                fontSize: 15,
                                                height: 1.45,
                                                fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w400,
                                                color: isCurrentlyPlaying ? Colors.white : Colors.white.withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(CupertinoIcons.pencil, size: 16, color: Colors.white54),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _editSegment(seg),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
