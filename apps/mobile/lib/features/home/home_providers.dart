import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/providers/core_providers.dart';

final recentMemoriesProvider = StreamProvider<List<Memory>>((ref) {
  final dao = ref.watch(memoriesDaoProvider);
  return dao.watchAll(limit: 5);
});

final processingQueueProvider = StreamProvider<int>((ref) {
  final dao = ref.watch(jobsDaoProvider);
  return dao.watchPendingCount();
});
