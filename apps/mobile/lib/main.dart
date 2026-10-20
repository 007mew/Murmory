import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:murmory/app/app.dart';
import 'package:murmory/core/providers/core_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  final container = ProviderContainer();
  // Initialize default tags and backfill any untranscribed voice notes
  unawaited(container.read(tagsServiceProvider).initializeDefaultTags());
  unawaited(container.read(transcriptionPipelineProvider).backfillMissingTranscripts());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MurmoryApp(),
    ),
  );
}
