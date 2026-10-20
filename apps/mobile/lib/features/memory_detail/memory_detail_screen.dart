import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
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
  bool _isPlaying = false;
  Duration _currentPos = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final memoriesDao = ref.read(memoriesDaoProvider);
    final memory = await memoriesDao.getById(widget.id);
    if (memory != null && memory.audioFilePath.isNotEmpty) {
      try {
        await _player.setFilePath(memory.audioFilePath);
        _player.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state.playing && state.processingState != ProcessingState.completed;
            });
          }
        });
        _player.positionStream.listen((pos) {
          if (mounted) setState(() => _currentPos = pos);
        });
        _player.durationStream.listen((dur) {
          if (mounted && dur != null) setState(() => _totalDuration = dur);
        });
      } catch (_) {}
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
    final transcriptDao = ref.watch(transcriptDaoProvider);
    final tagsService = ref.watch(tagsServiceProvider);
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
              stream: memoriesDao.watchById(widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator(color: Colors.white));
                }

                final memory = snapshot.data;
                if (memory == null) {
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
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // iOS Navigation Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LiquidGlass(
                              blur: 16,
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
                                  blur: 16,
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
                                  blur: 16,
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
                              stream: tagsService.watchTagsForMemory(memory.id),
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

                            // Liquid Glass Audio Player
                            LiquidGlass(
                              blur: 20,
                              borderRadius: 24,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_currentPos),
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
                                      value: _totalDuration.inMilliseconds > 0
                                          ? (_currentPos.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
                                          : 0.0,
                                      onChanged: (val) {
                                        final target = Duration(milliseconds: (val * _totalDuration.inMilliseconds).round());
                                        _player.seek(target);
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
                                        onPressed: () {
                                          final target = _currentPos - const Duration(seconds: 10);
                                          _player.seek(target < Duration.zero ? Duration.zero : target);
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          if (_isPlaying) {
                                            _player.pause();
                                          } else {
                                            if (_currentPos >= _totalDuration) {
                                              _player.seek(Duration.zero);
                                            }
                                            _player.play();
                                          }
                                        },
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
                                        onPressed: () {
                                          final target = _currentPos + const Duration(seconds: 10);
                                          _player.seek(target > _totalDuration ? _totalDuration : target);
                                        },
                                      ),
                                    ],
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
                              stream: transcriptDao.watchSegmentsForMemory(memory.id),
                              builder: (context, snap) {
                                final segments = snap.data ?? [];

                                if (segments.isEmpty) {
                                  return LiquidGlass(
                                    blur: 16,
                                    borderRadius: 20,
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        const Icon(CupertinoIcons.waveform, size: 40, color: MurmoryColors.accentLight),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No transcript yet',
                                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Run on-device transcription or transcribe with Whisper.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55)),
                                        ),
                                        const SizedBox(height: 16),
                                        CupertinoButton.filled(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          onPressed: () {
                                            final pipeline = ref.read(transcriptionPipelineProvider);
                                            pipeline.processMemory(memory.id, memory.audioFilePath, memory.durationMs);
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(CupertinoIcons.arrow_clockwise, size: 16),
                                              SizedBox(width: 8),
                                              Text('Transcribe Now'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: segments.length,
                                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) {
                                    final seg = segments[i];
                                    final isCurrentlyPlaying = currentMs >= seg.startMs && currentMs < seg.endMs;
                                    final startSec = (seg.startMs / 1000).round();
                                    final minStr = (startSec ~/ 60).toString().padLeft(2, '0');
                                    final secStr = (startSec % 60).toString().padLeft(2, '0');

                                    return LiquidGlass(
                                      blur: 14,
                                      borderRadius: 16,
                                      padding: const EdgeInsets.all(14),
                                      opacity: isCurrentlyPlaying ? 0.20 : 0.06,
                                      borderOpacity: isCurrentlyPlaying ? 0.45 : 0.12,
                                      tintColor: isCurrentlyPlaying ? MurmoryColors.accent : Colors.white,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        _player.seek(Duration(milliseconds: seg.startMs));
                                        if (!_isPlaying) _player.play();
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isCurrentlyPlaying
                                                  ? MurmoryColors.accent
                                                  : Colors.white.withValues(alpha: 0.1),
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
