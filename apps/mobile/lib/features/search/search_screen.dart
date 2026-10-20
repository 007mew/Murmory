import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
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
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
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
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final tagsService = ref.watch(tagsServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // iOS-Style Search Bar Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      LiquidGlass(
                        blur: 16,
                        borderRadius: 20,
                        padding: EdgeInsets.zero,
                        onTap: () => context.pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LiquidGlass(
                          blur: 20,
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.search, color: Colors.white60, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _controller,
                                  autofocus: true,
                                  placeholder: 'Search voice memories...',
                                  placeholderStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 15,
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
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
                                    size: 16,
                                    color: Colors.white54,
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
                      height: 40,
                      margin: const EdgeInsets.only(top: 8),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? MurmoryColors.accent.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Search Results
                Expanded(
                  child: _isSearching
                      ? const Center(child: CupertinoActivityIndicator(color: Colors.white))
                      : _results.isEmpty
                          ? Center(
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
                                        CupertinoIcons.search,
                                        size: 48,
                                        color: Colors.white.withValues(alpha: 0.35),
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
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _controller.text.isEmpty
                                          ? 'Instant local FTS5 search across all transcripts and titles.'
                                          : 'Try searching for related keywords or topics.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _results.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final res = _results[i];
                                final memory = _memoryMap[res.memoryId];
                                final durationSec = memory != null ? (memory.durationMs / 1000).round() : 0;
                                final minStr = (durationSec ~/ 60).toString().padLeft(2, '0');
                                final secStr = (durationSec % 60).toString().padLeft(2, '0');
                                final dateStr = memory != null
                                    ? DateFormat('MMM d, h:mm a').format(memory.createdAt)
                                    : '';

                                return LiquidGlass(
                                  blur: 18,
                                  borderRadius: 18,
                                  padding: const EdgeInsets.all(14),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/memories/${res.memoryId}');
                                  },
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
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: MurmoryColors.accent.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$minStr:$secStr',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: MurmoryColors.accentLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      _buildSnippetText(res.snippet),
                                      if (dateStr.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
