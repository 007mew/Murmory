import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/providers/core_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final memoriesDao = ref.watch(memoriesDaoProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Murmory',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: MurmoryColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
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
                    const SizedBox(height: 36),
                    Center(
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                context.push('/recording');
                              },
                              child: Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                                      blurRadius: 36,
                                      spreadRadius: 6,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Tap to speak',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Capture thoughts instantly',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MurmoryColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Memories',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/memories'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<Memory>>(
              stream: memoriesDao.watchAll(limit: 5),
              builder: (context, snapshot) {
                final memories = snapshot.data ?? [];

                if (memories.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.graphic_eq_rounded,
                              size: 64,
                              color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your mind, recorded & remembered',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap the purple button above to start your first memory recording.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MurmoryColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: memories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final durationSecs = (memory.durationMs / 1000).round();
                      final mins = (durationSecs ~/ 60).toString().padLeft(2, '0');
                      final secs = (durationSecs % 60).toString().padLeft(2, '0');
                      final dateFormatted = DateFormat('MMM d, h:mm a').format(memory.createdAt);

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
                                      Text(
                                        memory.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            dateFormatted,
                                            style: TextStyle(
                                              color: MurmoryColors.textSecondaryLight.withValues(alpha: 0.7),
                                              fontSize: 12,
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
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
