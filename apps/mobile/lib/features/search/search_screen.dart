import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/daos/transcript_dao.dart';
import 'package:murmory/core/providers/core_providers.dart';
import 'package:murmory/core/tags/tags_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<FtsSearchResult> _results = [];
  Map<String, Memory> _memoryMap = {};
  bool _isSearching = false;
  String _selectedTag = 'All';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final transcriptDao = ref.read(transcriptDaoProvider);
    final memoriesDao = ref.read(memoriesDaoProvider);

    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() => _isSearching = true);

    try {
      final ftsResults = await transcriptDao.searchTranscripts(query);

      // Fetch memory details for each unique memory_id
      final uniqueMemoryIds = ftsResults.map((r) => r.memoryId).toSet();
      final map = <String, Memory>{};
      for (final id in uniqueMemoryIds) {
        final m = await memoriesDao.getById(id);
        if (m != null) map[id] = m;
      }

      if (mounted) {
        setState(() {
          _results = ftsResults;
          _memoryMap = map;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Widget _buildSnippetText(String snippet) {
    // Snippet from SQLite FTS contains <b>matched</b> tags
    final spans = <TextSpan>[];
    final regex = RegExp(r'<b>(.*?)<\/b>');
    int lastIndex = 0;

    for (final match in regex.allMatches(snippet)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: snippet.substring(lastIndex, match.start),
          style: const TextStyle(color: MurmoryColors.textSecondaryLight, fontSize: 13),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: MurmoryColors.accentLight,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < snippet.length) {
      spans.add(TextSpan(
        text: snippet.substring(lastIndex),
        style: const TextStyle(color: MurmoryColors.textSecondaryLight, fontSize: 13),
      ));
    }

    if (spans.isEmpty) {
      return Text(snippet, style: const TextStyle(color: MurmoryColors.textSecondaryLight, fontSize: 13));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final tagsService = ref.watch(tagsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search spoken words, topics...',
            hintStyle: TextStyle(color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.6)),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
            _onSearchChanged(val);
          },
        ),
      ),
      body: Column(
        children: [
          // Quick tag filter row
          StreamBuilder<List<TagItem>>(
            stream: tagsService.watchAllTags(),
            builder: (context, snap) {
              final tags = snap.data ?? [];
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedTag == 'All',
                      onSelected: (sel) {
                        setState(() => _selectedTag = 'All');
                      },
                    ),
                    const SizedBox(width: 8),
                    ...tags.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(t.name),
                          selected: _selectedTag == t.name,
                          onSelected: (sel) {
                            setState(() => _selectedTag = sel ? t.name : 'All');
                            _controller.text = t.name.replaceAll('#', '');
                            _performSearch(_controller.text);
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

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _controller.text.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 60,
                              color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Search Your Voice Vault',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Instant SQLite FTS5 search across all transcripts',
                              style: TextStyle(fontSize: 12, color: MurmoryColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No exact matches for "${_controller.text}"',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Try searching for a different word or topic',
                                  style: TextStyle(fontSize: 12, color: MurmoryColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _results.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final item = _results[i];
                              final memory = _memoryMap[item.memoryId];
                              final title = memory?.title ?? 'Voice Note';
                              final dateStr = memory != null
                                  ? DateFormat('MMM d, h:mm a').format(memory.createdAt)
                                  : '';
                              final durSec = memory != null ? (memory.durationMs / 1000).round() : 0;
                              final mins = (durSec ~/ 60).toString().padLeft(2, '0');
                              final secs = (durSec % 60).toString().padLeft(2, '0');

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/memories/${item.memoryId}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: _buildSnippetText(item.snippet),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
