import 'package:drift/drift.dart';
import 'package:murmory/core/database/tables/memories_table.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get colorHex => text().withDefault(const Constant('#6C63FF'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MemoryTags extends Table {
  TextColumn get memoryId =>
      text().references(Memories, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {memoryId, tagId};
}
