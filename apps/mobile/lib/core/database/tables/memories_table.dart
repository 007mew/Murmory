import 'package:drift/drift.dart';

class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get audioFilePath => text()();
  TextColumn get audioFileHash => text().withDefault(const Constant(''))();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get transcriptStatus => text().withDefault(const Constant('pending'))();
  // pending | processing | done | failed
  TextColumn get summaryStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get processingMode => text().withDefault(const Constant('local'))();
  // local | cloud
  TextColumn get languageCode => text().withDefault(const Constant('en'))();
  TextColumn get rawMetadataJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}
