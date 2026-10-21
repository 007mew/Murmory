import 'dart:async';
import 'package:flutter/cupertino.dart';
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
    final spans = <TextSpan>[];
    final regex = RegExp(r'<b>(.*?)<\/b>');
    int lastIndex = 0;

    for (final match in regex.allMatches(snippet)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: snippet.substring(lastIndex, match.start),
          style: const TextStyle(color: MurmoryColors.textSecondary, fontSize: 13),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          color: MurmoryColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < snippet.length) {
      spans.add(TextSpan(
        text: snippet.substring(lastIndex),
        style: const TextStyle(color: MurmoryColors.textSecondary, fontSize: 13),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final tagsService = ref.watch(tagsServiceProvider);

    return Scaffold(
      backgroundColor: MurmoryColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // iOS-Style Search Bar Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.cardShadow,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(CupertinoIcons.chevron_back, color: MurmoryColors.textPrimary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: MurmoryColors.cardBorder),
                        boxShadow: MurmoryColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.search, color: MurmoryColors.textSecondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CupertinoTextField(
                              controller: _controller,
                              autofocus: true,
                              placeholder: 'Search voice memories...',
                              placeholderStyle: const TextStyle(
                                color: MurmoryColors.textTertiary,
                                fontSize: 15,
                              ),
                              style: const TextStyle(color: MurmoryColors.textPrimary, fontSize: 15),
                              decoration: null,
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                _onSearchChanged('');
                              },
                              child: const Icon(
                                CupertinoIcons.clear_thick_circled,
                                size: 18,
                                color: MurmoryColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tags Filter Bar
            StreamBuilder<List<TagItem>>(
              stream: tagsService.watchAllTags(),
              builder: (context, snap) {
                final tags = snap.data ?? [];
                if (tags.isEmpty) return const SizedBox.shrink();

                final filterOptions = ['All', ...tags.map((t) => t.name)];

                return Container(
                  height: 38,
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final item = filterOptions[i];
                      final isSelected = _selectedTag == item;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTag = item);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MurmoryColors.primaryBlue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? MurmoryColors.primaryBlue
                                  : MurmoryColors.cardBorder,
                              width: 1.0,
                            ),
                            boxShadow: isSelected ? null : MurmoryColors.cardShadow,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : MurmoryColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            // Search Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CupertinoActivityIndicator(color: MurmoryColors.primaryBlue))
                  : _results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: MurmoryColors.cardBorder),
                                    boxShadow: MurmoryColors.cardShadow,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    CupertinoIcons.search,
                                    size: 32,
                                    color: MurmoryColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _controller.text.isEmpty
                                      ? 'Search any word or idea'
                                      : 'No memories matched "${_controller.text}"',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: MurmoryColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _controller.text.isEmpty
                                      ? 'Instant local search across all transcripts and notes.'
                                      : 'Try searching for related keywords or topics.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: MurmoryColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final res = _results[i];
                            final memory = _memoryMap[res.memoryId];
                            final durationSec = memory != null ? (memory.durationMs / 1000).round() : 0;
                            final minStr = (durationSec ~/ 60).toString().padLeft(2, '0');
                            final secStr = (durationSec % 60).toString().padLeft(2, '0');
                            final dateStr = memory != null
                                ? DateFormat('MMM d, h:mm a').format(memory.createdAt)
                                : '';

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/memories/${res.memoryId}');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: MurmoryColors.cardBorder),
                                  boxShadow: MurmoryColors.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            memory?.title ?? 'Voice Memory',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: MurmoryColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: MurmoryColors.primaryBlue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$minStr:$secStr',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: MurmoryColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSnippetText(res.snippet),
                                    if (dateStr.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: MurmoryColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
