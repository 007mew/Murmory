import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      location: '/',
    ),
    _NavItem(
      label: 'Memories',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      location: '/memories',
    ),
    _NavItem(
      label: 'Ask',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      location: '/ask',
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      location: '/settings',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    context.go(_items[index].location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
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
