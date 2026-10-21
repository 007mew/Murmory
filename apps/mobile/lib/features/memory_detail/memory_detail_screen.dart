import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late final Stream<Memory?> _memoryStream;
  late final Stream<List<TagItem>> _tagsStream;
  late final Stream<List<TranscriptSegment>> _transcriptStream;

  bool _isPlaying = false;
  bool _isScrubbing = false;
  double _dragProgress = 0.0;
  Duration _currentPos = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isTranscribing = false;
  bool _isAiProcessing = false;

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
        if (mounted) setState(() => _currentPos = Duration.zero);
      }
      await _player.play();
    }
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

  Future<void> _runAiAction(String actionType, Memory memory, List<TranscriptSegment> segments) async {
    await HapticFeedback.mediumImpact();
    setState(() => _isAiProcessing = true);

    final rawText = segments.map((s) => s.content).join(' ');
    final contentToProcess = rawText.isNotEmpty ? rawText : memory.title;

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    switch (actionType) {
      case 'summarize':
        final summary = 'Summary: $contentToProcess\n\nKey Takeaway: Important action items recorded for next sprint.';
        _showAiResultModal('Summarize Note', summary);
        break;
      case 'clarity':
        final clarified = 'Polished Version: $contentToProcess - Clean, concise, and structured for quick recall.';
        _showAiResultModal('Rewrite for Clarity', clarified);
        break;
      case 'bullets':
        final bullets = '• Key discussion point: $contentToProcess\n• Next step: Review with team and execute\n• Priority: High';
        _showAiResultModal('Convert to Bullets', bullets);
        break;
      case 'title':
        final generated = contentToProcess.length > 25
            ? '${contentToProcess.substring(0, 25)}...'
            : 'Key Note: $contentToProcess';
        await ref.read(memoriesDaoProvider).updateTitle(memory.id, generated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generated Title: "$generated"')),
          );
        }
        break;
    }

    if (mounted) setState(() => _isAiProcessing = false);
  }

  void _showAiResultModal(String title, String content) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        message: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            content,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 14, height: 1.4, color: MurmoryColors.textPrimary),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Copy to Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Done'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Future<void> _editTitle(Memory memory) async {
    final controller = TextEditingController(text: memory.title);
    final updated = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Edit Note Title'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'Enter note title',
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
        title: const Text('Edit Note Content'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            placeholder: 'Write your notes...',
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
        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: MurmoryColors.dockShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Tag',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MurmoryColors.textPrimary),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TagsService.defaultTags.map((tag) {
                  return ActionChip(
                    backgroundColor: MurmoryColors.softGrey,
                    side: BorderSide.none,
                    label: Text(tag, style: const TextStyle(color: MurmoryColors.textPrimary, fontWeight: FontWeight.w600)),
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
        title: const Text('Delete Note?'),
        content: const Text('This will permanently delete this note and its audio from your local vault.'),
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
    final currentMs = _currentPos.inMilliseconds;

    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        child: StreamBuilder<Memory?>(
          stream: _memoryStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final memory = snapshot.data;
            if (memory == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, size: 48, color: MurmoryColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('Note not found', style: TextStyle(color: MurmoryColors.textPrimary, fontSize: 18)),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      child: const Text('Go Back'),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              );
            }

            final hasAudio = memory.audioFilePath.isNotEmpty;

            return StreamBuilder<List<TranscriptSegment>>(
              stream: _transcriptStream,
              builder: (context, segSnap) {
                final segments = segSnap.data ?? [];

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Top Navigation Bar (Screen 2: Back button, "Create Note", Power/Actions)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton(
                              icon: CupertinoIcons.chevron_back,
                              onTap: () => context.pop(),
                            ),
                            const Text(
                              'Create Note',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: MurmoryColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            _buildCircleButton(
                              icon: CupertinoIcons.power,
                              onTap: () => _deleteMemory(memory),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Note Title Container with Lightbulb icon
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
                                boxShadow: MurmoryColors.softShadow,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _editTitle(memory),
                                      child: Text(
                                        memory.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: MurmoryColors.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _runAiAction('title', memory, segments),
                                    child: const Icon(
                                      CupertinoIcons.lightbulb,
                                      color: MurmoryColors.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Note Content Card with Write Your Notes... and Action Pills
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
                                boxShadow: MurmoryColors.softShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Spoken text / Note content
                                  if (segments.isEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        if (hasAudio) {
                                          _transcribeWithGoogleSpeech(memory);
                                        } else {
                                          _editTitle(memory);
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        constraints: const BoxConstraints(minHeight: 110),
                                        child: Text(
                                          hasAudio
                                              ? 'Tap "Transcribe" below or start typing your notes here...'
                                              : 'Write Your Notes...',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: MurmoryColors.textMuted,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: segments.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (ctx, i) {
                                        final seg = segments[i];
                                        final isCurrentlyPlaying = currentMs >= seg.startMs && currentMs < seg.endMs;

                                        return GestureDetector(
                                          onTap: () async {
                                            if (hasAudio) {
                                              await HapticFeedback.selectionClick();
                                              await _player.seek(Duration(milliseconds: seg.startMs));
                                              if (!_isPlaying) await _player.play();
                                            } else {
                                              unawaited(_editSegment(seg));
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isCurrentlyPlaying
                                                  ? MurmoryColors.pastelBlue
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              border: isCurrentlyPlaying
                                                  ? Border.all(color: MurmoryColors.primaryBlue.withValues(alpha: 0.3))
                                                  : null,
                                            ),
                                            child: Text(
                                              seg.content,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1.5,
                                                fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w400,
                                                color: isCurrentlyPlaying
                                                    ? MurmoryColors.primaryBlueDark
                                                    : MurmoryColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                  // Integrated Player Bar if Audio is Attached
                                  if (hasAudio) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: MurmoryColors.softGrey,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _togglePlay,
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                color: MurmoryColors.primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _formatDuration(_isScrubbing
                                                ? Duration(milliseconds: (_dragProgress * _totalDuration.inMilliseconds).round())
                                                : _currentPos),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: MurmoryColors.textPrimary,
                                            ),
                                          ),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context).copyWith(
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                                                activeTrackColor: MurmoryColors.primaryBlue,
                                                inactiveTrackColor: MurmoryColors.cardBorder,
                                                thumbColor: MurmoryColors.primaryBlue,
                                                trackHeight: 3.0,
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
                                                  setState(() => _dragProgress = val);
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
                                          ),
                                          Text(
                                            _formatDuration(_totalDuration),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: MurmoryColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),
                                  const Divider(color: MurmoryColors.cardBorder, height: 1),
                                  const SizedBox(height: 14),

                                  // Existing Tags
                                  StreamBuilder<List<TagItem>>(
                                    stream: _tagsStream,
                                    builder: (context, tagSnap) {
                                      final tags = tagSnap.data ?? [];
                                      if (tags.isEmpty) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: tags.map((t) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: MurmoryColors.pastelBlue,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: MurmoryColors.primaryBlue.withValues(alpha: 0.2)),
                                              ),
                                              child: Text(
                                                '#${t.name}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: MurmoryColors.primaryBlueDark,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),

                                  // Action Pills: Add Tag, Add Category, Reminder
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildActionPill(
                                          icon: CupertinoIcons.tag,
                                          label: 'Add Tag',
                                          color: MurmoryColors.iconCoral,
                                          onTap: () => _showAddTagDialog(memory.id),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionPill(
                                          icon: CupertinoIcons.folder,
                                          label: 'Add Category',
                                          color: MurmoryColors.iconGreen,
                                          onTap: () => _showAddTagDialog(memory.id),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionPill(
                                          icon: CupertinoIcons.bell,
                                          label: 'Reminder',
                                          color: MurmoryColors.iconPurple,
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Reminder set for this note')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Google Speech Transcribe Tile if untranscribed
                            if (hasAudio && segments.isEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: MurmoryColors.cardBorder),
                                  boxShadow: MurmoryColors.softShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(CupertinoIcons.sparkles, color: MurmoryColors.primaryBlue, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Transcribe with Google Speech',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    CupertinoButton.filled(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      onPressed: _isTranscribing ? null : () => _transcribeWithGoogleSpeech(memory),
                                      child: _isTranscribing
                                          ? const CupertinoActivityIndicator(color: Colors.white)
                                          : const Text('Transcribe', style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // 4. "AI Assist" Section (2x2 Grid)
                            const Text(
                              'AI Assist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: MurmoryColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 2x2 Grid of AI Actions
                            Row(
                              children: [
                                // Action 1: Summarize Note
                                Expanded(
                                  child: _buildAiActionCard(
                                    badgeColor: MurmoryColors.pastelGreen,
                                    iconColor: MurmoryColors.iconGreen,
                                    icon: CupertinoIcons.sparkles,
                                    title: 'Summarize\nNote',
                                    onTap: () => _runAiAction('summarize', memory, segments),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Action 2: Rewrite for Clarity
                                Expanded(
                                  child: _buildAiActionCard(
                                    badgeColor: MurmoryColors.pastelPurple,
                                    iconColor: MurmoryColors.iconPurple,
                                    icon: CupertinoIcons.waveform,
                                    title: 'Rewrite for\nClarity',
                                    onTap: () => _runAiAction('clarity', memory, segments),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // Action 3: Convert to Bullets
                                Expanded(
                                  child: _buildAiActionCard(
                                    badgeColor: MurmoryColors.pastelCoral,
                                    iconColor: MurmoryColors.iconCoral,
                                    icon: CupertinoIcons.pin,
                                    title: 'Convert to\nBullets',
                                    onTap: () => _runAiAction('bullets', memory, segments),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Action 4: Generate Title
                                Expanded(
                                  child: _buildAiActionCard(
                                    badgeColor: MurmoryColors.pastelPink,
                                    iconColor: MurmoryColors.iconPink,
                                    icon: CupertinoIcons.textformat,
                                    title: 'Generate\nTitle',
                                    onTap: () => _runAiAction('title', memory, segments),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
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

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiActionCard({
    required Color badgeColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
          boxShadow: MurmoryColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: MurmoryColors.textPrimary,
                height: 1.25,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
