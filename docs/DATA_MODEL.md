# Murmory Data Model Specification

## Relational Schema (Drift / SQLite)

### 1. `memories` Table
Primary entity representing a recorded audio thought.
- `id` (TEXT, Primary Key, UUIDv4)
- `owner_id` (TEXT, Nullable, for future cloud auth)
- `title` (TEXT, Non-null, default fallback to timestamp)
- `created_at_utc` (DATETIME, Non-null)
- `updated_at_utc` (DATETIME, Non-null)
- `duration_ms` (INTEGER, Non-null)
- `relative_audio_path` (TEXT, Non-null, relative to app files root)
- `audio_mime_type` (TEXT, Non-null, e.g. 'audio/m4a')
- `audio_size_bytes` (INTEGER, Non-null)
- `audio_sha256` (TEXT, Non-null)
- `language_code` (TEXT, Nullable)
- `is_favorite` (BOOLEAN, Non-null, default false)
- `is_archived` (BOOLEAN, Non-null, default false)
- `processing_status` (TEXT, Non-null: 'unprocessed', 'queued', 'transcribed', 'failed')
- `sync_status` (TEXT, Non-null: 'local_only', 'synced', 'pending_upload', 'pending_delete')
- `deleted_at_utc` (DATETIME, Nullable, tombstone timestamp)
- `schema_version` (INTEGER, Non-null, default 1)

### 2. `transcript_segments` Table
Timestamped transcription chunks aligned with playback.
- `id` (TEXT, Primary Key, UUIDv4)
- `memory_id` (TEXT, Non-null, Foreign Key references memories(id) ON DELETE CASCADE)
- `start_ms` (INTEGER, Non-null)
- `end_ms` (INTEGER, Non-null)
- `text` (TEXT, Non-null)
- `speaker_id` (TEXT, Nullable)
- `source` (TEXT, Non-null: 'machine', 'user_edit', 'import')
- `confidence` (REAL, Nullable)
- `created_at_utc` (DATETIME, Non-null)
- `updated_at_utc` (DATETIME, Non-null)

### 3. `transcript_fts` (Virtual Table - FTS5)
Full-text search index matching `transcript_segments(id, memory_id, text)`.

### 4. `tags` and `memory_tags`
- `tags`: `id`, `name`, `normalized_name`, `created_at_utc`
- `memory_tags`: `memory_id`, `tag_id` (Composite Primary Key)

### 5. `processing_jobs` Table
Durable job queue for background tasks (transcription, summaries, uploads).
- `id` (TEXT, Primary Key, UUIDv4)
- `memory_id` (TEXT, Non-null)
- `job_type` (TEXT, Non-null: 'transcription', 'summary', 'upload')
- `status` (TEXT, Non-null: 'queued', 'processing', 'retry_scheduled', 'failed', 'completed')
- `attempt_count` (INTEGER, Non-null, default 0)
- `idempotency_key` (TEXT, Non-null, Unique)
- `last_error_code` (TEXT, Nullable)
- `next_retry_at_utc` (DATETIME, Nullable)
- `created_at_utc` (DATETIME, Non-null)
- `updated_at_utc` (DATETIME, Non-null)
