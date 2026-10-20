import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:murmory/core/database/database.dart';

class TagItem {
  final String id;
  final String name;
  final String colorHex;

  const TagItem({
    required this.id,
    required this.name,
    this.colorHex = '#6C63FF',
  });
}

class TagsService {
  final AppDatabase _db;

  TagsService(this._db);

  static const defaultTags = [
    '#idea',
    '#todo',
    '#meeting',
    '#personal',
    '#reflection',
  ];

  Future<void> initializeDefaultTags() async {
    for (final name in defaultTags) {
      await getOrCreateTag(name);
    }
  }

  Future<TagItem> getOrCreateTag(String name, {String colorHex = '#6C63FF'}) async {
    final cleanName = name.startsWith('#') ? name : '#$name';
    final existing = await _db.customSelect(
      'SELECT id, name, color_hex FROM tags WHERE name = ? LIMIT 1',
      variables: [Variable.withString(cleanName)],
    ).getSingleOrNull();

    if (existing != null) {
      return TagItem(
        id: existing.read<String>('id'),
        name: existing.read<String>('name'),
        colorHex: existing.read<String>('color_hex'),
      );
    }

    final id = const Uuid().v4();
    await _db.customStatement(
      'INSERT INTO tags (id, name, color_hex, created_at) VALUES (?, ?, ?, ?)',
      [id, cleanName, colorHex, DateTime.now().millisecondsSinceEpoch],
    );

    return TagItem(id: id, name: cleanName, colorHex: colorHex);
  }

  Stream<List<TagItem>> watchAllTags() {
    return _db.customSelect(
      'SELECT id, name, color_hex FROM tags ORDER BY name ASC',
      readsFrom: {_db.tags},
    ).watch().map((rows) {
      return rows.map((r) => TagItem(
        id: r.read<String>('id'),
        name: r.read<String>('name'),
        colorHex: r.read<String>('color_hex'),
      )).toList();
    });
  }

  Stream<List<TagItem>> watchTagsForMemory(String memoryId) {
    return _db.customSelect(
      '''
      SELECT t.id, t.name, t.color_hex
      FROM tags t
      INNER JOIN memory_tags mt ON mt.tag_id = t.id
      WHERE mt.memory_id = ?
      ORDER BY t.name ASC
      ''',
      variables: [Variable.withString(memoryId)],
      readsFrom: {_db.tags, _db.memoryTags},
    ).watch().map((rows) {
      return rows.map((r) => TagItem(
        id: r.read<String>('id'),
        name: r.read<String>('name'),
        colorHex: r.read<String>('color_hex'),
      )).toList();
    });
  }

  Future<void> addTagToMemory(String memoryId, String tagName) async {
    final tag = await getOrCreateTag(tagName);
    await _db.customStatement(
      'INSERT OR IGNORE INTO memory_tags (memory_id, tag_id) VALUES (?, ?)',
      [memoryId, tag.id],
    );
  }

  Future<void> removeTagFromMemory(String memoryId, String tagId) async {
    await _db.customStatement(
      'DELETE FROM memory_tags WHERE memory_id = ? AND tag_id = ?',
      [memoryId, tagId],
    );
  }
}
