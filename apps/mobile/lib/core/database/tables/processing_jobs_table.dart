import 'package:drift/drift.dart';
import 'package:murmory/core/database/tables/memories_table.dart';

class ProcessingJobs extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId =>
      text().references(Memories, #id, onDelete: KeyAction.cascade)();
  TextColumn get jobType => text()();
  // transcription | summarization | extraction
  TextColumn get status => text().withDefault(const Constant('queued'))();
  // queued | running | done | failed | cancelled
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  IntColumn get maxAttempts => integer().withDefault(const Constant(3))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get resultJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
