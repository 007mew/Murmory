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
      appBar: AppBar(
        title: const Text('Memories Library', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search memories',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          StreamBuilder<List<TagItem>>(
            stream: tagsService.watchAllTags(),
            builder: (context, snap) {
              final tags = snap.data ?? [];
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _activeFilter == 'All',
                      onSelected: (sel) {
                        setState(() => _activeFilter = 'All');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.favorite_rounded, size: 14, color: Colors.redAccent),
                      label: const Text('Favorites'),
                      selected: _activeFilter == 'Favorites',
                      onSelected: (sel) {
                        setState(() => _activeFilter = sel ? 'Favorites' : 'All');
                      },
                    ),
                    const SizedBox(width: 8),
                    ...tags.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(t.name),
                          selected: _activeFilter == t.name,
                          onSelected: (sel) {
                            setState(() => _activeFilter = sel ? t.name : 'All');
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // Memories List
          Expanded(
            child: StreamBuilder<List<Memory>>(
              stream: memoriesDao.watchAll(
                favoritesOnly: _activeFilter == 'Favorites',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final memories = snapshot.data ?? [];

                if (memories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bubble_chart_outlined,
                          size: 64,
                          color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _activeFilter == 'Favorites'
                              ? 'No favorite memories yet'
                              : 'No voice memories yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _activeFilter == 'Favorites'
                              ? 'Tap the heart icon on any memory to favorite it.'
                              : 'Recordings captured on Home will appear here.',
                          style: const TextStyle(color: MurmoryColors.textSecondaryLight, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: memories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final memory = memories[index];
                    final durationSecs = (memory.durationMs / 1000).round();
                    final mins = (durationSecs ~/ 60).toString().padLeft(2, '0');
                    final secs = (durationSecs % 60).toString().padLeft(2, '0');
                    final dateFormatted = DateFormat('MMM d, yyyy • h:mm a').format(memory.createdAt);

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/memories/${memory.id}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: MurmoryColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: MurmoryColors.accentLight,
                                  size: 26,
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
                                            memory.title.isEmpty ? 'Voice Thought' : memory.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                        ),
                                        if (memory.isFavorite)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(Icons.favorite_rounded, size: 14, color: Colors.redAccent),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          dateFormatted,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        Text(
                                          '  •  ',
                                          style: TextStyle(
                                            color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.4),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$mins:$secs',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 22,
                              ),
                            ],
                          ),
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
    );
  }
}
