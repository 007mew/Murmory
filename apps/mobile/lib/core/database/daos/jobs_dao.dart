import 'package:drift/drift.dart';
import 'package:murmory/core/database/database.dart';
import 'package:murmory/core/database/tables/processing_jobs_table.dart';

part 'jobs_dao.g.dart';

@DriftAccessor(tables: [ProcessingJobs])
class JobsDao extends DatabaseAccessor<AppDatabase> with _$JobsDaoMixin {
  JobsDao(super.db);

  /// Watch pending/running jobs count
  Stream<int> watchPendingCount() {
    final count = processingJobs.id.count();
    return (selectOnly(processingJobs)
          ..addColumns([count])
          ..where(processingJobs.status.isIn(['queued', 'running'])))
        .watchSingle()
        .map((r) => r.read(count) ?? 0);
  }

  /// Get all jobs for a memory
  Future<List<ProcessingJob>> getJobsForMemory(String memoryId) {
    return (select(processingJobs)
          ..where((t) => t.memoryId.equals(memoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Insert a job
  Future<void> insertJob(ProcessingJobsCompanion job) async {
    await into(processingJobs).insert(job);
  }

  /// Update job status
  Future<void> updateStatus(
    String jobId,
    String status, {
    String? errorMessage,
    String? resultJson,
  }) async {
    await (update(processingJobs)..where((t) => t.id.equals(jobId))).write(
      ProcessingJobsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
        attempt: const Value.absent(),
        errorMessage:
            errorMessage != null ? Value(errorMessage) : const Value.absent(),
        resultJson:
            resultJson != null ? Value(resultJson) : const Value.absent(),
      ),
    );
  }

  /// Increment attempt count
  Future<void> incrementAttempt(String jobId) async {
    await db.customStatement(
      'UPDATE processing_jobs SET attempt = attempt + 1, updated_at = ? WHERE id = ?',
      [DateTime.now().millisecondsSinceEpoch, jobId],
    );
  }

  /// Cancel all jobs for a memory
  Future<void> cancelJobsForMemory(String memoryId) async {
    await (update(processingJobs)
          ..where((t) =>
              t.memoryId.equals(memoryId) &
              t.status.isIn(['queued', 'running'])))
        .write(ProcessingJobsCompanion(
      status: const Value('cancelled'),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
