import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/daos/memories_dao.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/providers/core_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Stream<List<Memory>> _memoriesStream;

  @override
  void initState() {
    super.initState();
    _memoriesStream = ref.read(memoriesDaoProvider).watchAll(limit: 10);
  }

  Future<void> _showQuickTextNoteDialog() async {
    final controller = TextEditingController();
    final titleController = TextEditingController();

    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Create Text Note'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                controller: titleController,
                placeholder: 'Note Title',
                autofocus: true,
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: controller,
                placeholder: 'Write your thoughts...',
                maxLines: 4,
              ),
            ],
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
            onPressed: () async {
              final text = controller.text.trim();
              final title = titleController.text.trim();
              if (text.isNotEmpty || title.isNotEmpty) {
                final memoriesDao = ref.read(memoriesDaoProvider);
                final now = DateTime.now();
                final id = 'note_${now.millisecondsSinceEpoch}';
                await memoriesDao.insertMemory(
                  MemoriesCompanion(
                    id: drift.Value(id),
                    title: drift.Value(title.isEmpty ? 'Quick Note' : title),
                    createdAt: drift.Value(now),
                    updatedAt: drift.Value(now),
                    audioFilePath: const drift.Value(''),
                    durationMs: const drift.Value(0),
                    transcriptStatus: const drift.Value('completed'),
                  ),
                );
                final transcriptDao = ref.read(transcriptDaoProvider);
                await transcriptDao.insertSegments([
                  TranscriptSegmentsCompanion(
                    id: drift.Value('seg_${now.millisecondsSinceEpoch}'),
                    memoryId: drift.Value(id),
                    sequenceIndex: const drift.Value(0),
                    startMs: const drift.Value(0),
                    endMs: const drift.Value(0),
                    content: drift.Value(text.isEmpty ? title : text),
                    speakerLabel: const drift.Value('Me'),
                  ),
                ]);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoriesDao = ref.watch(memoriesDaoProvider);

    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Profile Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Profile Info
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'JD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Jhon Dong',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MurmoryColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Graphics Designer',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: MurmoryColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Top Action Buttons (Settings & Bell)
                    Row(
                      children: [
                        _buildTopCircularButton(
                          icon: CupertinoIcons.gear_alt,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/settings');
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildTopCircularButton(
                          icon: CupertinoIcons.bell,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vault is healthy • All data stored locally'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/search');
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
                      boxShadow: MurmoryColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.search,
                          color: MurmoryColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Search notes, tags...',
                            style: TextStyle(
                              color: MurmoryColors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            context.push('/recording');
                          },
                          child: const Icon(
                            CupertinoIcons.mic,
                            color: MurmoryColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. 2x2 Feature Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Column(
                  children: [
                    // Row 1: Text Note & Voice Note
                    Row(
                      children: [
                        // Card 1: Text Note
                        Expanded(
                          child: _buildFeatureCard(
                            isFeatured: false,
                            iconWidget: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: MurmoryColors.softGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'T',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: MurmoryColors.textPrimary,
                                ),
                              ),
                            ),
                            title: 'Text Note',
                            subtitle: 'Write and save your\nthoughts',
                            onTap: () => _showQuickTextNoteDialog(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Card 2: Voice Note (Active Royal Blue)
                        Expanded(
                          child: _buildFeatureCard(
                            isFeatured: true,
                            iconWidget: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x20000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.waveform,
                                color: MurmoryColors.primaryBlue,
                                size: 20,
                              ),
                            ),
                            title: 'Voice Note',
                            subtitle: 'Record and save your\nvoice',
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              context.push('/recording');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Row 2: Image Note & AI Note
                    Row(
                      children: [
                        // Card 3: Image Note
                        Expanded(
                          child: _buildFeatureCard(
                            isFeatured: false,
                            iconWidget: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: MurmoryColors.softGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.photo,
                                color: MurmoryColors.textPrimary,
                                size: 19,
                              ),
                            ),
                            title: 'Image Note',
                            subtitle: 'Capture notes from\nimages',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image attachment mode')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Card 4: AI Note
                        Expanded(
                          child: _buildFeatureCard(
                            isFeatured: false,
                            iconWidget: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: MurmoryColors.softGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.sparkles,
                                color: MurmoryColors.textPrimary,
                                size: 19,
                              ),
                            ),
                            title: 'AI Note',
                            subtitle: 'Create notes with AI\nassistance',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/ask');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. "Recent Notes" Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: MurmoryColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/memories'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: MurmoryColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Recent Notes List
            StreamBuilder<List<Memory>>(
              stream: _memoriesStream,
              builder: (context, snapshot) {
                final memories = snapshot.data ?? [];

                if (memories.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: MurmoryColors.cardBorder),
                          boxShadow: MurmoryColors.softShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: MurmoryColors.pastelBlue,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.mic,
                                color: MurmoryColors.primaryBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No notes recorded yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MurmoryColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap the blue Voice Note card above to capture your first memory.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: MurmoryColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final memory = memories[index];
                        return _buildRecentNoteCard(context, memory, memoriesDao);
                      },
                      childCount: memories.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCircularButton({
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

  Widget _buildFeatureCard({
    required bool isFeatured,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 148,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFeatured ? MurmoryColors.primaryBlue : Colors.white,
          gradient: isFeatured
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isFeatured
              ? null
              : Border.all(color: MurmoryColors.cardBorder, width: 1.0),
          boxShadow: isFeatured ? MurmoryColors.blueGlow : MurmoryColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconWidget,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isFeatured ? Colors.white : MurmoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: isFeatured
                        ? Colors.white.withValues(alpha: 0.85)
                        : MurmoryColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNoteCard(
    BuildContext context,
    Memory memory,
    MemoriesDao memoriesDao,
  ) {
    final timeStr = DateFormat('MMM d, h:mm a').format(memory.createdAt);
    final relativeDays = DateTime.now().difference(memory.createdAt).inDays;
    final relativeTime = relativeDays == 0
        ? 'Today'
        : (relativeDays == 1 ? '1 Day Ago' : '$relativeDays Days Ago');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
        boxShadow: MurmoryColors.softShadow,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/memories/${memory.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & 3-dots Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    memory.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MurmoryColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showNoteActions(context, memory, memoriesDao),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      color: MurmoryColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bullet / Action Item row
            Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 15,
                  color: MurmoryColors.primaryBlue.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    memory.durationMs > 0
                        ? 'Audio voice memo (${(memory.durationMs / 1000).round()}s recorded)'
                        : 'Quick text capture',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: MurmoryColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Row: Tag Pills & Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag Pills
                Row(
                  children: [
                    _buildTagPill('Personal'),
                    const SizedBox(width: 6),
                    _buildTagPill('Journal'),
                  ],
                ),

                // Relative Date with Calendar Icon
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 13,
                      color: MurmoryColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      relativeTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MurmoryColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MurmoryColors.softGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MurmoryColors.textSecondary,
        ),
      ),
    );
  }

  void _showNoteActions(
    BuildContext context,
    Memory memory,
    MemoriesDao memoriesDao,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(memory.title),
        actions: [
          CupertinoActionSheetAction(
            child: Text(memory.isFavorite ? 'Unfavorite' : 'Mark as Favorite'),
            onPressed: () async {
              Navigator.pop(ctx);
              await memoriesDao.toggleFavorite(memory.id, !memory.isFavorite);
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text('Delete Note'),
            onPressed: () async {
              Navigator.pop(ctx);
              await memoriesDao.softDelete(memory.id);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}
