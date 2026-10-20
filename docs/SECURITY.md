# Murmory Security & Privacy Specification

## Principles

1. **Default Privacy:** No audio, transcripts, or personal data leave the device by default.
2. **Explicit Opt-in:** Cloud synchronization, AI transcription, or semantic retrieval services require conscious, transparent opt-in.
3. **No Hardcoded Secrets:** Client packages contain zero API keys, service role tokens, or private secrets.
4. **Sandboxed Storage:** All audio recordings and SQLite databases reside strictly inside app-private directories (`Context.getFilesDir()` on Android, `NSApplicationSupportDirectory` on iOS).

## Permissions Architecture

- **Microphone (`RECORD_AUDIO`):** Only requested contextually when the user initiates their first recording. Never requested at app startup.
- **Foreground Service (`FOREGROUND_SERVICE_MICROPHONE`):** Utilized on Android 14+ solely to prevent OS process reaping during long recordings while backgrounded.
- **No Extraneous Permissions:** Murmory never requests Location, Contacts, Camera, or Phone State permissions.

## Data Retention & Deletion

- When a user deletes a memory, deletion is deterministic across:
  - Local SQLite relational row & FTS5 search index entries
  - Audio file from internal storage
  - Cached waveforms / metadata
- In the event of cloud synchronization:
  - A cryptographically tracked tombstone record is committed.
  - Remote deletion propagates to private cloud buckets and Supabase tables upon the next active connection.
