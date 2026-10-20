import 'package:drift/drift.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/tables/memories_table.dart';

part 'memories_dao.g.dart';

@DriftAccessor(tables: [Memories])
class MemoriesDao extends DatabaseAccessor<AppDatabase>
    with _$MemoriesDaoMixin {
  MemoriesDao(super.db);

  /// Watch all memories ordered by createdAt descending
  Stream<List<Memory>> watchAll({
    bool favoritesOnly = false,
    bool archivedOnly = false,
    int limit = 20,
    int offset = 0,
  }) {
    var query = select(memories)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    if (favoritesOnly) {
      query.where((t) => t.isFavorite.equals(true));
    } else if (archivedOnly) {
      query.where((t) => t.isArchived.equals(true));
    } else {
      query.where((t) => t.isArchived.equals(false));
    }

    return query.watch();
  }

  /// Get a single memory by ID
  Future<Memory?> getById(String id) {
    return (select(memories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch a single memory by ID
  Stream<Memory?> watchById(String id) {
    return (select(memories)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Get recent memories (last N)
  Future<List<Memory>> getRecent(int limit) {
    return (select(memories)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Insert a new memory
  Future<void> insertMemory(MemoriesCompanion entry) async {
    await into(memories).insert(entry);
  }

  /// Update a memory
  Future<bool> updateMemory(MemoriesCompanion entry) {
    return update(memories).replace(entry);
  }

  /// Delete a memory by ID
  Future<int> deleteById(String id) {
    return (delete(memories)..where((t) => t.id.equals(id))).go();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id, bool value) async {
    await (update(memories)..where((t) => t.id.equals(id))).write(
      MemoriesCompanion(
        isFavorite: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggle archived
  Future<void> toggleArchived(String id, bool value) async {
    await (update(memories)..where((t) => t.id.equals(id))).write(
      MemoriesCompanion(
        isArchived: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update transcript status
  Future<void> updateTranscriptStatus(String id, String status) async {
    await (update(memories)..where((t) => t.id.equals(id))).write(
      MemoriesCompanion(
        transcriptStatus: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update title
  Future<void> updateTitle(String id, String title) async {
    await (update(memories)..where((t) => t.id.equals(id))).write(
      MemoriesCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Count non-archived memories
  Future<int> countAll() async {
    final count = await (selectOnly(memories)
          ..addColumns([memories.id.count()])
          ..where(memories.isArchived.equals(false)))
        .getSingle();
    return count.read(memories.id.count()) ?? 0;
  }
}
