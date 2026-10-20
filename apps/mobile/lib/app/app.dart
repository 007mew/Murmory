import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:murmory/app/router.dart';
import 'package:murmory/core/design_system/theme.dart';

class MurmoryApp extends ConsumerWidget {
  const MurmoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Murmory',
      debugShowCheckedModeBanner: false,
      theme: MurmoryTheme.light(),
      darkTheme: MurmoryTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
