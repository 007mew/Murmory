import 'package:drift/drift.dart';
import 'package:murmory/core/database/tables/memories_table.dart';

class TranscriptSegments extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId =>
      text().references(Memories, #id, onDelete: KeyAction.cascade)();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get content => text()();
  RealColumn get confidence => real().withDefault(const Constant(1.0))();
  IntColumn get speakerLabel => integer().nullable()();
  IntColumn get sequenceIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {memoryId, sequenceIndex},
      ];
}
