import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:murmory/core/design_system/tokens.dart';
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
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter memory title',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
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
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Transcript Segment'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Correct spoken text',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
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
      backgroundColor: MurmoryColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Tag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TagsService.defaultTags.map((tag) {
                  return ActionChip(
                    label: Text(tag),
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
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'New custom tag (e.g. #strategy)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        await tagsService.addTagToMemory(memoryId, text);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text('This will permanently delete the audio recording and transcript from your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: MurmoryColors.recordRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final memoriesDao = ref.read(memoriesDaoProvider);
      final fileManager = ref.read(audioFileManagerProvider);
      if (memory.audioFilePath.isNotEmpty) {
        await fileManager.deleteAudio(memory.audioFilePath);
      }
      await memoriesDao.deleteById(memory.id);
      if (mounted) context.pop();
    }
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
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

    return StreamBuilder<Memory?>(
      stream: memoriesDao.watchById(widget.id),
      builder: (context, snapshot) {
        final memory = snapshot.data;
        if (memory == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Memory not found')),
          );
        }

        final dateFormatted = DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(memory.createdAt);
        final currentMs = _currentPos.inMilliseconds;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Memory Detail'),
            actions: [
              IconButton(
                icon: Icon(
                  memory.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: memory.isFavorite ? Colors.redAccent : null,
                ),
                tooltip: 'Toggle Favorite',
                onPressed: () async {
                  await HapticFeedback.lightImpact();
                  await memoriesDao.toggleFavorite(memory.id, !memory.isFavorite);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: MurmoryColors.recordRed),
                tooltip: 'Delete Memory',
                onPressed: () => _deleteMemory(memory),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with Edit Pencil
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        memory.title.isEmpty ? 'Untitled Thought' : memory.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Title',
                      onPressed: () => _editTitle(memory),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatted,
                  style: const TextStyle(
                    fontSize: 13,
                    color: MurmoryColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),

                // Tags row
                StreamBuilder<List<TagItem>>(
                  stream: tagsService.watchTagsForMemory(memory.id),
                  builder: (context, snap) {
                    final tags = snap.data ?? [];
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...tags.map((tag) {
                          return Chip(
                            label: Text(tag.name, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close_rounded, size: 16),
                            onDeleted: () => unawaited(tagsService.removeTagFromMemory(memory.id, tag.id)),
                            backgroundColor: MurmoryColors.accent.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          );
                        }),
                        ActionChip(
                          avatar: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Tag', style: TextStyle(fontSize: 12)),
                          onPressed: () => _showAddTagDialog(memory.id),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Audio Player Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPos),
                            style: const TextStyle(
                              fontSize: 13,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: const TextStyle(
                              fontSize: 13,
                              color: MurmoryColors.textSecondaryLight,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _totalDuration.inMilliseconds > 0
                              ? (_currentPos.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
                              : 0.0,
                          onChanged: (val) {
                            final seekTarget = Duration(milliseconds: (val * _totalDuration.inMilliseconds).round());
                            _player.seek(seekTarget);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10_rounded),
                            iconSize: 28,
                            tooltip: 'Rewind 10s',
                            onPressed: () {
                              final target = _currentPos - const Duration(seconds: 10);
                              _player.seek(target < Duration.zero ? Duration.zero : target);
                            },
                          ),
                          const SizedBox(width: 16),
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
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: MurmoryColors.accent,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.forward_10_rounded),
                            iconSize: 28,
                            tooltip: 'Forward 10s',
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

                // Interactive Transcript Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transcript',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Tap sentence to jump',
                      style: TextStyle(
                        fontSize: 12,
                        color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.8),
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
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.transcribe_rounded, size: 40, color: MurmoryColors.accentLight),
                            const SizedBox(height: 12),
                            const Text(
                              'Generating offline transcript...',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Transcribing strictly on-device without cloud upload.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: MurmoryColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                final pipeline = ref.read(transcriptionPipelineProvider);
                                pipeline.processMemory(memory.id, memory.audioFilePath, memory.durationMs);
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Transcribe Now'),
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

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _player.seek(Duration(milliseconds: seg.startMs));
                            if (!_isPlaying) _player.play();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying
                                  ? MurmoryColors.accent.withValues(alpha: 0.22)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentlyPlaying
                                    ? MurmoryColors.accentLight
                                    : Colors.white.withValues(alpha: 0.06),
                                width: isCurrentlyPlaying ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCurrentlyPlaying
                                        ? MurmoryColors.accent
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$minStr:$secStr',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentlyPlaying ? Colors.white : MurmoryColors.textSecondaryLight,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    seg.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w400,
                                      color: isCurrentlyPlaying ? Colors.white : Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  color: Colors.white38,
                                  tooltip: 'Edit sentence',
                                  onPressed: () => _editSegment(seg),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
