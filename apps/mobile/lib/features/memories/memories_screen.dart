import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: 40,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS-Style Top Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Memories',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color: Colors.white,
                        ),
                      ),
                      LiquidGlass(
                        blur: 16,
                        borderRadius: 22,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/search');
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Frosted Liquid Filter Chips Row
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
                                    ? (isFav ? Colors.redAccent.withValues(alpha: 0.25) : MurmoryColors.accent.withValues(alpha: 0.35))
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (isFav ? Colors.redAccent.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.3))
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isFav) ...[
                                    Icon(
                                      CupertinoIcons.heart_fill,
                                      size: 13,
                                      color: isSelected ? Colors.redAccent : Colors.white60,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? Colors.white : Colors.white70,
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
                        return const Center(child: CupertinoActivityIndicator(color: Colors.white));
                      }

                      final memories = snapshot.data ?? [];

                      if (memories.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LiquidGlass(
                                  blur: 16,
                                  borderRadius: 36,
                                  padding: const EdgeInsets.all(24),
                                  child: Icon(
                                    _activeFilter == 'Favorites'
                                        ? CupertinoIcons.heart
                                        : CupertinoIcons.waveform_path,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _activeFilter == 'Favorites'
                                      ? 'No favorite memories yet'
                                      : 'No voice memories yet',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _activeFilter == 'Favorites'
                                      ? 'Tap the heart icon inside any memory to pin it to favorites.'
                                      : 'Tap the glowing mic on Home to record your first thought.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: memories.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          final durationSecs = (memory.durationMs / 1000).round();
                          final mins = (durationSecs ~/ 60).toString().padLeft(2, '0');
                          final secs = (durationSecs % 60).toString().padLeft(2, '0');
                          final dateFormatted = DateFormat('MMM d, yyyy • h:mm a').format(memory.createdAt);

                          return LiquidGlass(
                            blur: 18,
                            borderRadius: 18,
                            padding: const EdgeInsets.all(14),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/memories/${memory.id}');
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        MurmoryColors.accent.withValues(alpha: 0.4),
                                        const Color(0xFF6366F1).withValues(alpha: 0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.play_arrow_solid,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              memory.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.white,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          if (memory.isFavorite) ...[
                                            const SizedBox(width: 6),
                                            const Icon(
                                              CupertinoIcons.heart_fill,
                                              color: Colors.redAccent,
                                              size: 14,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            dateFormatted,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '  •  ',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.3),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.12),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              '$mins:$secs',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  size: 16,
                                ),
                              ],
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
        ],
      ),
    );
  }
}
