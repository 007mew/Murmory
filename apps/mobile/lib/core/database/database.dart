import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:murmory/core/database/tables/memories_table.dart';
import 'package:murmory/core/database/tables/processing_jobs_table.dart';
import 'package:murmory/core/database/tables/tags_table.dart';
import 'package:murmory/core/database/tables/transcript_segments_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Memories,
    TranscriptSegments,
    Tags,
    MemoryTags,
    ProcessingJobs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Create FTS5 virtual table for transcript search
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS transcript_fts
            USING fts5(
              memory_id UNINDEXED,
              segment_id UNINDEXED,
              content,
              content=transcript_segments,
              content_rowid=rowid
            )
          ''');
          // Trigger to keep FTS in sync on insert
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_ai
            AFTER INSERT ON transcript_segments BEGIN
              INSERT INTO transcript_fts(rowid, memory_id, segment_id, content)
              VALUES (new.rowid, new.memory_id, new.id, new.content);
            END
          ''');
          // Trigger to keep FTS in sync on update
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_au
            AFTER UPDATE ON transcript_segments BEGIN
              INSERT INTO transcript_fts(transcript_fts, rowid, memory_id, segment_id, content)
              VALUES ('delete', old.rowid, old.memory_id, old.id, old.content);
              INSERT INTO transcript_fts(rowid, memory_id, segment_id, content)
              VALUES (new.rowid, new.memory_id, new.id, new.content);
            END
          ''');
          // Trigger to keep FTS in sync on delete
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_ad
            AFTER DELETE ON transcript_segments BEGIN
              INSERT INTO transcript_fts(transcript_fts, rowid, memory_id, segment_id, content)
              VALUES ('delete', old.rowid, old.memory_id, old.id, old.content);
            END
          ''');
        },
        beforeOpen: (details) async {
          // Drop stale triggers from initial creation that referenced old column name 'text'
          await customStatement('DROP TRIGGER IF EXISTS transcript_ai');
          await customStatement('DROP TRIGGER IF EXISTS transcript_au');
          await customStatement('DROP TRIGGER IF EXISTS transcript_ad');
          await customStatement('DROP TABLE IF EXISTS transcript_fts');

          // Ensure FTS table and triggers exist with correct column 'content'
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS transcript_fts
            USING fts5(
              memory_id UNINDEXED,
              segment_id UNINDEXED,
              content,
              content=transcript_segments,
              content_rowid=rowid
            )
          ''');
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_ai
            AFTER INSERT ON transcript_segments BEGIN
              INSERT INTO transcript_fts(rowid, memory_id, segment_id, content)
              VALUES (new.rowid, new.memory_id, new.id, new.content);
            END
          ''');
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_au
            AFTER UPDATE ON transcript_segments BEGIN
              INSERT INTO transcript_fts(transcript_fts, rowid, memory_id, segment_id, content)
              VALUES ('delete', old.rowid, old.memory_id, old.id, old.content);
              INSERT INTO transcript_fts(rowid, memory_id, segment_id, content)
              VALUES (new.rowid, new.memory_id, new.id, new.content);
            END
          ''');
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS transcript_ad
            AFTER DELETE ON transcript_segments BEGIN
              INSERT INTO transcript_fts(transcript_fts, rowid, memory_id, segment_id, content)
              VALUES ('delete', old.rowid, old.memory_id, old.id, old.content);
            END
          ''');
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'murmory_db');
}
