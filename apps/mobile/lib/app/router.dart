import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/features/ask/ask_screen.dart';
import 'package:murmory/features/home/home_screen.dart';
import 'package:murmory/features/memories/memories_screen.dart';
import 'package:murmory/features/memory_detail/memory_detail_screen.dart';
import 'package:murmory/features/recording/recording_screen.dart';
import 'package:murmory/features/search/search_screen.dart';
import 'package:murmory/features/settings/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) => _router);

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/memories',
          builder: (context, state) => const MemoriesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => MemoryDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/ask',
          builder: (context, state) => const AskScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/recording',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RecordingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
  ],
);

class _ScaffoldWithNavBar extends StatefulWidget {
  const _ScaffoldWithNavBar({required this.child});
  final Widget child;

  @override
  State<_ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<_ScaffoldWithNavBar> {
  int _currentIndex = 0;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
      location: '/',
    ),
    _NavItem(
      label: 'Memories',
      icon: CupertinoIcons.waveform_path,
      selectedIcon: CupertinoIcons.waveform_path_badge_plus,
      location: '/memories',
    ),
    _NavItem(
      label: 'Ask',
      icon: CupertinoIcons.sparkles,
      selectedIcon: CupertinoIcons.sparkles,
      location: '/ask',
    ),
    _NavItem(
      label: 'Settings',
      icon: CupertinoIcons.gear_alt,
      selectedIcon: CupertinoIcons.gear_alt_fill,
      location: '/settings',
    ),
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    context.go(_items[index].location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(33),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final isSelected = _currentIndex == index;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onDestinationSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 16 : 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MurmoryColors.accent.withValues(alpha: 0.35)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
                                  width: 1.0,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? Colors.white : Colors.white60,
                              size: 22,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
