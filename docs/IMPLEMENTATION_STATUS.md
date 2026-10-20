# Murmory Implementation Status

## Milestones 0 to 5 Complete (Verified on Physical Device)

### Milestone 0: Workspace & Toolchain
- [x] Java 21 LTS (`jdk-21.0.12.101-hotspot`) configured.
- [x] Flutter 3.32.5 / Dart 3.8 toolchains configured and registered in PATH.
- [x] Android SDK 34 / 35 with build-tools, platform-tools (`adb`), cmdline-tools.
- [x] Physical Android device (`I2301`, Android 15, `10BE2U29D5000U6`) paired and verified.

### Milestone 1: Local Audio Capture & Playback Engine
- [x] Native AAC-LC recording adapter (`RecordAudioRecorder`) with audio amplitude streaming.
- [x] Reactive recording state machine (`recordingProvider`): idle, recording, paused, finalizing.
- [x] Hardware playback engine (`JustAudioService`) with position stream, duration, and seek.
- [x] Foreground service & microphone permissions (`RECORD_AUDIO`, `FOREGROUND_SERVICE_MICROPHONE`).

### Milestone 2: Local Memory Vault & Drift SQLite
- [x] Pure local SQLite database via Drift with reactive DAOs:
  - `MemoriesDao`: CRUD, favorites, soft deletion, tagging, and recency streams.
  - `TranscriptDao`: Multi-segment transcript management with exact keyword indexing.
  - `JobsDao`: Asynchronous background processing queue.
- [x] Core navigation shell with GoRouter:
  - Home Screen (quick capture card, memory metrics, recent list).
  - Memories Screen (full vault library, search trigger).

### Milestone 3: Background Transcription & Live Audio Sync
- [x] Transcription Pipeline & Service:
  - Background processing queue parsing audio recordings into timestamped segment blocks.
  - Automatic memory title generation and status transition (`transcribed`).
- [x] Interactive Transcript UI:
  - Real-time purple sentence glow synchronized with live audio playback.
  - Interactive tap-to-seek directly to sentence start timestamp.
  - In-place editable sentence content and memory title via modal dialogs.
- [x] SQLite FTS5 Exact Search:
  - Dedicated `SearchScreen` with debounced full-text query matching.
  - Search term highlighting with `<b>term</b>` snippets.

### Milestone 4: Semantic Search & "Ask Murmory" Grounded Q&A
- [x] Memory Retrieval Engine (`MemoryRetrievalService`):
  - Grounded question-answering synthesized strictly against indexed memory transcripts.
  - Traceable source citations (`RetrievedCitation`) linking responses directly to memory titles, start/end timestamps, and quote snippets.
  - Safe fallback when no grounded evidence exists ("I don't have enough information in your recorded memories...").
- [x] Interactive "Ask Murmory" Conversational UI:
  - Prompt pills ("What meetings did I record?", "Summarize my recent thoughts").
  - Local-first privacy badge and grounded response cards with clickable timestamp citations.

### Milestone 5: Smart Tags & Full Data Vault Export
- [x] Tagging System (`TagsService`):
  - Preloaded tags (`#idea`, `#todo`, `#meeting`, `#personal`, `#reflection`).
  - Memory-tag associations with tag filtering chip bar in Memories Library.
- [x] Vault Data Export (`VaultExportService`):
  - Full local-first ZIP packaging using pure Dart `archive`.
  - Includes SQLite records JSON, original `.m4a` audio files, human-readable markdown summaries, and `manifest_sha256.json`.
- [x] Settings & Privacy Controls:
  - Real-time vault storage calculation.
  - One-tap ZIP export dialog with SHA-256 verification.
  - Strict local-only privacy isolation.

---

## Next Steps: Milestone 6 (Release Readiness)
1. **Device Matrix & Optimization**:
   - Audio session management on phone call interruption and bluetooth headset disconnects.
   - 60/120fps jank profiling and memory leak checks during long recording sessions.
2. **Release Build & Signing**:
   - Proguard/R8 shrinking configuration for release APK/AAB.
   - App signing keys generation.
