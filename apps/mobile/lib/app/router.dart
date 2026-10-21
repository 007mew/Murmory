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

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) => _router);

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _ScaffoldWithNavBar(
        currentPath: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/memories',
          builder: (context, state) => const MemoriesScreen(),
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
      parentNavigatorKey: _rootNavigatorKey,
      path: '/memories/:id',
      pageBuilder: (context, state) => CupertinoPage(
        key: state.pageKey,
        child: MemoryDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
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

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  int _currentIndex() {
    if (currentPath.startsWith('/memories')) return 1;
    if (currentPath.startsWith('/ask')) return 3;
    if (currentPath.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _currentIndex();
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(44, 0, 44, 18),
          height: 62,
          decoration: BoxDecoration(
            color: MurmoryColors.dockBackground,
            borderRadius: BorderRadius.circular(31),
            boxShadow: const [
              BoxShadow(
                color: Color(0x35000000),
                blurRadius: 24,
                spreadRadius: -2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Home
              _buildDockButton(
                context: context,
                isSelected: activeIndex == 0,
                icon: CupertinoIcons.house_alt_fill,
                unselectedIcon: CupertinoIcons.house_alt,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/');
                },
              ),

              // 2. Notes / Memories List
              _buildDockButton(
                context: context,
                isSelected: activeIndex == 1,
                icon: CupertinoIcons.doc_text_fill,
                unselectedIcon: CupertinoIcons.doc_text,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/memories');
                },
              ),

              // 3. Center (+) Action Pod (Vibrant Blue Circle)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/recording');
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: MurmoryColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D3B82F6),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // 4. Tasks / Ask Murmory
              _buildDockButton(
                context: context,
                isSelected: activeIndex == 3,
                icon: CupertinoIcons.checkmark_seal_fill,
                unselectedIcon: CupertinoIcons.checkmark_circle,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/ask');
                },
              ),

              // 5. Settings / More
              _buildDockButton(
                context: context,
                isSelected: activeIndex == 4,
                icon: CupertinoIcons.gear_alt_fill,
                unselectedIcon: CupertinoIcons.gear_alt,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockButton({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required IconData unselectedIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? MurmoryColors.primaryBlue : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          isSelected ? icon : unselectedIcon,
          color: isSelected ? Colors.white : Colors.white60,
          size: 21,
        ),
      ),
    );
  }
}
