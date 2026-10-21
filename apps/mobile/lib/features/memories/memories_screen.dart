import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/tags/tags_service.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  String _activeFilter = 'All'; // 'All' | 'Favorites' | '#tag'

  @override
  Widget build(BuildContext context) {
    final memoriesDao = ref.watch(memoriesDaoProvider);
    final tagsService = ref.watch(tagsServiceProvider);

    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: "Memories" & Search Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Memories',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: MurmoryColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/search');
                    },
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
                      child: const Icon(
                        CupertinoIcons.search,
                        color: MurmoryColors.textPrimary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips Row
            StreamBuilder<List<TagItem>>(
              stream: tagsService.watchAllTags(),
              builder: (context, snap) {
                final tags = snap.data ?? [];
                final filterItems = [
                  'All',
                  'Favorites',
                  ...tags.map((t) => t.name),
                ];

                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filterItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final item = filterItems[i];
                      final isSelected = _activeFilter == item;
                      final isFav = item == 'Favorites';

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeFilter = item);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isFav ? MurmoryColors.iconCoral : MurmoryColors.primaryBlue)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : MurmoryColors.cardBorder,
                              width: 1.0,
                            ),
                            boxShadow: isSelected
                                ? (isFav
                                    ? const [BoxShadow(color: Color(0x33EF4444), blurRadius: 8, offset: Offset(0, 2))]
                                    : MurmoryColors.blueGlow)
                                : MurmoryColors.softShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFav) ...[
                                Icon(
                                  CupertinoIcons.heart_fill,
                                  size: 13,
                                  color: isSelected ? Colors.white : MurmoryColors.iconCoral,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : MurmoryColors.textSecondary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Memories List
            Expanded(
              child: StreamBuilder<List<Memory>>(
                stream: memoriesDao.watchAll(
                  favoritesOnly: _activeFilter == 'Favorites',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final memories = snapshot.data ?? [];

                  if (memories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: MurmoryColors.cardBorder),
                                boxShadow: MurmoryColors.softShadow,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _activeFilter == 'Favorites'
                                    ? CupertinoIcons.heart
                                    : CupertinoIcons.waveform_path,
                                size: 30,
                                color: MurmoryColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _activeFilter == 'Favorites'
                                  ? 'No favorite notes yet'
                                  : 'No voice notes yet',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: MurmoryColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _activeFilter == 'Favorites'
                                  ? 'Mark any note with a heart to see it here.'
                                  : 'Tap the blue Voice Note card on Home to record your thoughts.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MurmoryColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: memories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final durationSecs = (memory.durationMs / 1000).round();
                      final mins = (durationSecs ~/ 60).toString().padLeft(2, '0');
                      final secs = (durationSecs % 60).toString().padLeft(2, '0');
                      final dateFormatted = DateFormat('MMM d, yyyy • h:mm a').format(memory.createdAt);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/memories/${memory.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: MurmoryColors.cardBorder, width: 1.0),
                            boxShadow: MurmoryColors.softShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: MurmoryColors.pastelBlue,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  CupertinoIcons.play_arrow_solid,
                                  color: MurmoryColors.primaryBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memory.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: MurmoryColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          dateFormatted,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: MurmoryColors.textSecondary,
                                          ),
                                        ),
                                        if (memory.durationMs > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: MurmoryColors.softGrey,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$mins:$secs',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: MurmoryColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_forward,
                                color: MurmoryColors.textMuted,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
