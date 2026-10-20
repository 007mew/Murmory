import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/liquid_glass.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient liquid glow orbs
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MurmoryColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 240,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
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
                                const Text(
                                  'Murmory',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.55),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
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
                        const SizedBox(height: 36),

                        // Center iOS Liquid Mic Button
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
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFA78BFA),
                                          Color(0xFF6366F1),
                                          Color(0xFF4F46E5),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.35),
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.55),
                                          blurRadius: 40,
                                          spreadRadius: 6,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.mic_fill,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Tap to speak',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Capture thoughts with private on-device intelligence',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Memories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => context.go('/memories'),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: MurmoryColors.accentLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<List<Memory>>(
                  stream: memoriesDao.watchAll(limit: 6),
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
                                LiquidGlass(
                                  blur: 16,
                                  borderRadius: 36,
                                  padding: const EdgeInsets.all(24),
                                  child: Icon(
                                    CupertinoIcons.waveform,
                                    size: 52,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Your mind, recorded & remembered',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap the glowing microphone above to start your first private voice note.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList.separated(
                        itemCount: memories.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          final durationSecs = (memory.durationMs / 1000).round();
                          final mins = (durationSecs ~/ 60).toString().padLeft(2, '0');
                          final secs = (durationSecs % 60).toString().padLeft(2, '0');
                          final dateFormatted = DateFormat('MMM d, h:mm a').format(memory.createdAt);

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
                                      Text(
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
