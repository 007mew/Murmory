# Murmory --- Product Requirements & Implementation Specification

> **Working brand:** Murmory\
> **Tagline:** Speak it. Find it.\
> **Product:** Private, searchable personal voice memory for Android and
> iOS\
> **Audience:** Antigravity Desktop coding agent\
> **Document status:** Implementation brief; validate all dependencies
> and provider choices before release.

------------------------------------------------------------------------

## 0. Instructions for Antigravity

Act as the senior mobile engineer, product designer, security engineer,
and QA lead for this project.

Your task is to build **Murmory**, a production-oriented, cross-platform
voice-memory application. Do not stop at mockups, a plan, or placeholder
screens. Inspect the existing workspace first, determine whether a
project already exists, preserve useful existing work, and implement the
application incrementally.

### Required working behavior

1.  Start by inspecting the repository, current files, installed SDKs,
    and existing app architecture.
2.  If the repository is empty, scaffold the app using the stack below.
    If an existing app is present, document the current stack and
    propose a safe migration before replacing anything.
3.  Create `README.md`, `docs/PRODUCT_REQUIREMENTS.md`,
    `docs/ARCHITECTURE.md`, `docs/SECURITY.md`, `docs/DATA_MODEL.md`,
    `docs/TEST_PLAN.md`, and `.env.example`.
4.  Implement a real, working offline-first recorder and local memory
    library before cloud AI.
5.  Use real persistence, real audio recording, and real playback. Do
    not substitute fake data or non-functional controls for core
    features.
6.  Keep the app buildable after each milestone. Run formatters, static
    analysis, unit tests, and platform builds whenever available.
7.  Maintain `docs/IMPLEMENTATION_STATUS.md` with completed work, test
    evidence, known issues, and next steps.
8.  Do not claim a feature works unless it has been implemented and
    tested. If a tool, API key, device, or platform SDK is unavailable,
    implement a clean interface and document what remains.
9.  Ask the user only when a decision is genuinely blocking. Otherwise
    choose a reasonable default and record it in `docs/DECISIONS.md`.
10. Never put API secrets in the mobile app, source control, logs,
    screenshots, or test fixtures.
11. Do not use fake success states. Errors, permission denials, network
    failures, and empty states must be handled explicitly.
12. Build the product in phases. Prioritize data integrity,
    accessibility, and privacy over feature count.

### First action

Inspect the workspace and report: - current project structure and
stack; - Android/iOS build prerequisites available; - existing code that
should be preserved; - blockers and proposed first milestone.

Then begin implementing the first milestone rather than ending with the
report.

------------------------------------------------------------------------

## 1. Product definition

### 1.1 Vision

Murmory is a personal memory system built around voice. A user records a
thought in seconds, keeps the original audio on their device, optionally
transcribes it, and later retrieves a detail across many recordings.

**Core promise:** Capture a thought once. Find it whenever you need it.

Murmory is not merely a voice recorder, a meeting bot, or a generic AI
chat interface. Its differentiator is trustworthy retrieval across the
user's own recordings, with source citations and timestamps.

### 1.2 Target users

-   People capturing ideas while walking, commuting, studying, or
    working.
-   Students and researchers recording explanations and observations.
-   Creators collecting story ideas, drafts, and inspiration.
-   Professionals remembering decisions, commitments, and project
    details.
-   People who prefer speaking to typing.

### 1.3 Product principles

1.  Capture must be faster than typing a note.
2.  Recording, playback, and organizing must work offline.
3.  Local capture must not require an account.
4.  Cloud AI must be optional and transparent.
5.  Original audio is immutable and never silently replaced by generated
    text.
6.  AI answers must cite real source memories.
7.  Users can export and delete their data.
8.  The app must remain useful if every AI service is unavailable.
9.  The UI should be calm, minimal, accessible, and responsive.
10. Never imply that the app is end-to-end encrypted unless the full
    architecture supports that claim.

### 1.4 Brand

-   Name: **Murmory** (working name; do not assume domain, app-store, or
    trademark availability).
-   Tagline: **Speak it. Find it.**
-   Voice: calm, clear, trustworthy, understated.
-   Avoid exaggerated AI claims, noisy gradients, excessive animation,
    and manipulative paywalls.
-   Before public launch, verify domains, social handles, app-store
    naming conflicts, and relevant trademarks in target markets.

------------------------------------------------------------------------

## 2. Platforms and technology

### 2.1 Primary stack

-   **Flutter + Dart** for a shared Android/iOS interface.
-   **Riverpod** for state management and dependency injection.
-   **GoRouter** for navigation.
-   **Drift + SQLite** for local relational persistence.
-   **SQLite FTS5** for exact/full-text transcript search where
    supported by the chosen build.
-   **Private app filesystem** for original audio and temporary files.
-   **Native Android and iOS audio adapters** for reliable recording
    lifecycle, interruption handling, and background behavior.
-   **Supabase/PostgreSQL** as the initial optional backend for
    authentication, metadata sync, and private object storage.
-   A server-side provider abstraction for transcription, embeddings,
    and LLM answer generation.
-   Platform keystore/keychain-backed secret protection.
-   Flutter integration tests plus native platform tests for critical
    audio lifecycle behavior.

Dependency selection must be verified against current stable releases,
platform compatibility, licenses, and maintenance status. Pin compatible
versions and commit the lockfile.

### 2.2 Architecture rules

-   Feature-first modular structure.
-   UI depends on domain/use-case interfaces, not directly on providers
    or database implementations.
-   Repositories abstract local storage, audio files, search, processing
    jobs, and optional cloud services.
-   Local data is the source of truth for the active device.
-   Cloud sync is an adapter, not a prerequisite for the core
    application.
-   Provider-specific code must be replaceable without rewriting product
    features.
-   All asynchronous operations need cancellation, error handling, and
    explicit states.
-   Never load entire long audio files into memory for upload or
    processing.
-   Use migrations for database schema changes.
-   No secrets in client-side environment variables that become bundled
    into the app.

### 2.3 Suggested structure

``` text
murmory/
├── README.md
├── .env.example
├── docs/
│   ├── PRODUCT_REQUIREMENTS.md
│   ├── ARCHITECTURE.md
│   ├── SECURITY.md
│   ├── DATA_MODEL.md
│   ├── TEST_PLAN.md
│   ├── DECISIONS.md
│   └── IMPLEMENTATION_STATUS.md
├── apps/
│   └── mobile/
│       ├── lib/
│       │   ├── app/
│       │   ├── core/
│       │   │   ├── audio/
│       │   │   ├── database/
│       │   │   ├── files/
│       │   │   ├── jobs/
│       │   │   ├── networking/
│       │   │   ├── security/
│       │   │   └── design_system/
│       │   ├── features/
│       │   │   ├── onboarding/
│       │   │   ├── home/
│       │   │   ├── recording/
│       │   │   ├── memories/
│       │   │   ├── memory_detail/
│       │   │   ├── transcript/
│       │   │   ├── search/
│       │   │   ├── ask/
│       │   │   ├── collections/
│       │   │   └── settings/
│       │   └── main.dart
│       ├── android/
│       ├── ios/
│       └── test/
├── backend/
│   ├── api/
│   ├── workers/
│   ├── retrieval/
│   ├── migrations/
│   └── tests/
└── scripts/
```

The structure is a guide, not a reason to create empty folders without
functionality. Adjust it to the actual framework conventions.

------------------------------------------------------------------------

## 3. Product scope and priorities

### P0 --- First usable release

-   Local onboarding without mandatory account creation.
-   Microphone permission flow.
-   Start, pause, resume, stop, save, and play recordings.
-   Robust handling of interruptions and interrupted finalization.
-   Memory list with title, date, duration, and status.
-   Rename, favorite, archive, delete, and basic tags.
-   Memory detail with audio player.
-   Optional transcription adapter and timestamped transcript model.
-   Transcript editing independent of original audio.
-   Exact text search across titles and available transcripts.
-   Processing queue with progress, errors, retries, and cancellation.
-   Export transcript and original audio.
-   Local privacy controls and clear data deletion.
-   Offline capture and playback.
-   Accessible layouts, loading states, empty states, and error states.

### P1 --- Core differentiators

-   Semantic search over transcripts.
-   "Ask my memories" natural-language retrieval.
-   Answer citations linked to transcript segments and audio timestamps.
-   AI summaries and extraction of tasks, decisions, and ideas.
-   Related-memory suggestions.
-   Collections and advanced filters.
-   Optional cloud sync and account recovery.
-   Hindi, English, and Hinglish evaluation and configuration.

### P2 --- Future work

-   On-device speech recognition and embeddings on supported devices.
-   Advanced speaker diarization.
-   Wearable quick capture.
-   Desktop companion.
-   Shared collections with explicit access control.
-   Calendar and task integrations.
-   Advanced knowledge graph.
-   End-to-end encrypted sync, only after a reviewed cryptographic
    design.

Do not block P0 on P1 or P2.

------------------------------------------------------------------------

## 4. User journeys

### 4.1 First launch

1.  Show a concise explanation: local recording works without an
    account; cloud AI is optional.
2.  Let the user continue into the app without signing in.
3.  Do not request microphone permission until the user taps Record.
4.  Explain the permission in context.
5.  If denied, provide a useful explanation and a Settings route; do not
    loop permission prompts.
6.  Do not ask for contacts, location, or unrelated permissions.

### 4.2 Capture a memory

1.  User taps Record.
2.  If permission is already granted, begin capture immediately after
    platform initialization.
3.  Show a clear recording state, elapsed time, and level
    meter/waveform.
4.  Provide Pause/Resume and Stop controls.
5.  On Stop, finalize and persist the audio before any transcription or
    upload.
6.  Create the local memory record and show the saved state.
7.  Offer title editing, tags, and transcription actions without
    blocking the save.
8.  If storage is low or finalization fails, show a recoverable error
    and preserve any recoverable temporary file.

### 4.3 Find a memory

1.  User searches for a word or phrase.
2.  Exact search works locally against titles and indexed transcript
    segments.
3.  Results show title, date, matching excerpt, and timestamp.
4.  Tapping a result opens the memory and seeks playback to the excerpt.
5.  Semantic search is clearly identified as optional if it requires a
    model or cloud processing.

### 4.4 Ask a question

1.  User asks a question about their own memories.
2.  App retrieves relevant transcript segments first.
3.  If cloud AI is disabled, offer local results and explain that
    generated answers require enabling an appropriate processor.
4.  If cloud AI is enabled, send only the minimum relevant content to
    the selected provider.
5.  Generate an answer grounded in retrieved evidence.
6.  Validate every citation against actual retrieved segment IDs.
7.  Show source memory, date, excerpt, and timestamp.
8.  If evidence is absent or conflicting, say so rather than guessing.

### 4.5 Delete a memory

1.  Confirm destructive action with a clear description.
2.  Stop active processing for that memory when possible.
3.  Delete audio, transcript, summaries, tags associations, extracted
    items, local indexes, embeddings, and queued local jobs.
4.  If cloud-synced, create a deletion tombstone and propagate it when
    connectivity returns.
5.  Show pending cloud deletion if offline.
6.  Never silently claim remote deletion has completed when the device
    is offline.

------------------------------------------------------------------------

## 5. Screen requirements

### 5.1 Navigation

Use four main destinations:

-   **Home** --- record and resume.
-   **Memories** --- browse and organize.
-   **Ask** --- question answering over memory.
-   **Settings** --- processing, privacy, storage, and sync.

Keep a prominent record action available from Home and optionally from
the Memories screen. Do not create a cluttered navigation drawer for a
small app.

### 5.2 Home

Components: - Product wordmark and date. - Large primary Record
action. - Short status text such as "Ready to capture". - Recent
memories. - Processing queue indicator. - Search entry point. -
Favorites or collections shortcut. - Storage status only when useful.

States: - First-use empty state. - Ready. - Recording. - Saving. -
Processing. - Offline. - Storage warning. - Microphone permission
denied.

### 5.3 Recording studio

Components: - Large elapsed-time display. - Waveform or level meter. -
Pause/Resume. - Stop. - Clear recording status. - Optional
marker/bookmark action only if implemented correctly.

Requirements: - Use monotonic timing for elapsed duration. - Respect OS
audio focus/session rules. - Define behavior for calls, alarms,
Bluetooth route changes, headphone removal, backgrounding, and app
termination. - Do not claim continuous background capture where the OS
or permission model does not permit it. - Show a visible
active-recording indicator.

### 5.4 Memories library

-   Chronological list or timeline.
-   Search field.
-   Filters: date, collection, favorite, archived, transcript status.
-   Sort by date, title, duration, relevance.
-   Multi-select for export and deletion.
-   Clear status labels for pending/failed transcription.
-   Empty, loading, and error states.
-   Pagination or efficient incremental loading for large libraries.

### 5.5 Memory detail

-   Editable title.
-   Date, time, duration, and tags.
-   Audio player with seek controls.
-   Transcript with timestamped segments.
-   Tap transcript segment to seek audio.
-   Optional summary and extracted items.
-   Source/processing status.
-   Export, archive, favorite, and delete actions.
-   Mark generated content as AI-generated.
-   Editing transcript must not modify original audio.

### 5.6 Search

Provide: - Exact text search. - Optional semantic search. - Filters and
sorting. - Snippet highlighting. - Timestamped results. - Keyboard and
screen-reader support. - Useful empty states and search errors.

Exact search must not depend on an LLM.

### 5.7 Ask

-   Chat-like but restrained interface.
-   Suggested example queries only when the library contains usable
    data.
-   Source citations on every factual answer.
-   Citation cards open the source memory at the relevant timestamp.
-   Show "No supporting memory found" where appropriate.
-   Distinguish direct statements, inferred conclusions, and conflicting
    sources.
-   Allow users to clear conversation history.
-   Do not send the full memory library to a provider when only a few
    excerpts are required.

### 5.8 Settings

Sections: - Processing mode. - Transcription language preferences. -
Cloud AI consent. - Cloud sync. - Wi-Fi-only uploads. - Storage usage. -
App lock/biometrics. - Export all data. - Delete local data. - Account
deletion where an account exists. - Privacy notice and provider
details. - Diagnostics opt-in, if diagnostics are added.

------------------------------------------------------------------------

## 6. Design system and UX quality

### Visual direction

-   Minimal, calm, premium utility.
-   Light and dark themes.
-   Neutral backgrounds, strong text contrast, one restrained accent
    color.
-   Consistent spacing, corner radii, typography, and icon style.
-   No excessive gradients, glass effects, or decorative animations.
-   Use motion only to communicate state changes.
-   Respect reduced-motion preferences and system font scaling.

### Interaction quality

-   One clear primary action per screen.
-   Record button must be unmistakable.
-   Touch targets should generally be at least 44--48 logical pixels.
-   Avoid tiny controls near the bottom edge.
-   Use haptics sparingly and only for meaningful actions.
-   Preserve scroll position and search query when navigating back.
-   Avoid layout jumps when transcript processing completes.
-   Never use color alone to indicate processing status.
-   Provide labels and semantics for screen readers.

### Accessibility

-   TalkBack and VoiceOver support.
-   Logical focus order.
-   Sufficient contrast.
-   Dynamic text scaling.
-   Accessible names for record, pause, resume, stop, seek, and delete
    controls.
-   Do not make waveform graphics the only way to understand recording
    state.

------------------------------------------------------------------------

## 7. Audio engine requirements

Create a platform abstraction with an explicit contract, for example:

``` dart
abstract interface class AudioRecorderService {
  Future<void> requestPermission();
  Future<void> start(String temporaryPath);
  Future<void> pause();
  Future<void> resume();
  Future<RecordedAudio> stop();
  Future<void> cancel();
  Stream<RecordingState> get stateStream;
  Stream<AudioLevel> get levelStream;
}
```

Adapt signatures to the chosen audio library. Do not pretend an
abstraction is implemented until its platform adapters are wired.

### Reliability rules

-   Persist to an app-private temporary file.
-   Finalize and validate the file before committing the memory record.
-   Use a crash-recovery reconciliation process at app startup.
-   Track temporary files, committed files, and orphaned files.
-   Avoid loading full recordings into RAM.
-   Support playback interruption and audio-route changes.
-   Enforce reasonable configurable duration and storage limits.
-   Warn before recording would exceed available storage.
-   Use a background/foreground service only where platform policy
    requires and permits it.
-   Ensure iOS audio session configuration and Android
    foreground-service declarations match actual behavior.
-   Test actual devices; simulators alone are insufficient for final
    audio acceptance.

### Audio formats

Select a practical compressed format supported by both platforms and
chosen libraries, such as AAC in an appropriate container. Keep the
format abstraction replaceable. Validate duration, size, decodability,
and playback after finalization.

------------------------------------------------------------------------

## 8. Data model

Use local UUIDs generated on-device so records can be created offline.

### `memories`

-   `id`
-   `owner_id` nullable for local-only use
-   `title`
-   `created_at_utc`
-   `updated_at_utc`
-   `duration_ms`
-   `relative_audio_path`
-   `audio_mime_type`
-   `audio_size_bytes`
-   `audio_sha256`
-   `language_code` nullable
-   `is_favorite`
-   `is_archived`
-   `processing_status`
-   `sync_status`
-   `deleted_at_utc` nullable
-   `schema_version`

### `transcript_segments`

-   `id`
-   `memory_id`
-   `start_ms`
-   `end_ms`
-   `text`
-   `speaker_id` nullable
-   `source` (`machine`, `user_edit`, `import`)
-   `confidence` nullable
-   `created_at_utc`
-   `updated_at_utc`

### `summaries`

-   `id`
-   `memory_id`
-   `summary_text`
-   `source_content_hash`
-   `provider_id`
-   `model_id`
-   `created_at_utc`
-   `status`

Mark a summary stale when its source transcript changes.

### `tags` and `memory_tags`

-   `tags(id, name, normalized_name, created_at_utc)`
-   `memory_tags(memory_id, tag_id)`

### `collections` and `collection_members`

-   `collections(id, title, description, created_at_utc, updated_at_utc)`
-   `collection_members(collection_id, memory_id, added_at_utc)`

### `extracted_items`

-   `id`
-   `memory_id`
-   `kind` (`task`, `decision`, `idea`, `fact`, `question`)
-   `text`
-   `source_start_ms`
-   `source_end_ms`
-   `confidence`
-   `status`
-   `due_at_utc` nullable
-   `user_confirmed`
-   `created_at_utc`

Extracted tasks must not create external reminders without user
confirmation.

### `processing_jobs`

-   `id`
-   `memory_id`
-   `job_type`
-   `status`
-   `attempt_count`
-   `idempotency_key`
-   `last_error_code`
-   `next_retry_at_utc`
-   `created_at_utc`
-   `updated_at_utc`

### `embeddings`

-   `id`
-   `memory_id`
-   `segment_id`
-   `model_id`
-   `content_hash`
-   `vector_storage_ref`
-   `created_at_utc`

Avoid putting large vector blobs in ordinary memory rows. Select a
vector index after measuring mobile performance and storage
requirements.

### Additional records

-   User preferences and processing consent.
-   Device sync cursors.
-   Deletion tombstones.
-   Provider usage ledger.
-   Subscription entitlements.
-   Export jobs.
-   Optional audit events without transcript content.

### Database invariants

-   Foreign keys enabled.
-   Transactions used for related metadata changes.
-   Indexed foreign keys and common filters.
-   Unique constraints for normalized tags and idempotency keys.
-   UTC timestamps; display in device timezone.
-   Audio paths relative to app-private storage.
-   Original audio immutable after finalization.
-   Migrations tested against old schema versions.
-   Rebuildable search indexes derived from canonical records.

### Example transcript segment

``` json
{
  "id": "segment_uuid",
  "memory_id": "memory_uuid",
  "start_ms": 12500,
  "end_ms": 18700,
  "text": "I should review the architecture on Friday.",
  "speaker_id": null,
  "source": "machine",
  "confidence": null
}
```

------------------------------------------------------------------------

## 9. Recording persistence and recovery

Use this ordered save strategy:

1.  Record to a temporary file in private app storage.
2.  Stop and finalize the encoder.
3.  Verify that the file exists, is readable, and has a plausible
    duration.
4.  Calculate file size and a content hash without loading the entire
    file into memory.
5.  Move/rename the file to its permanent relative path using the safest
    available atomic operation.
6.  Commit metadata in a database transaction.
7.  Enqueue transcription only after the recording is safely persisted.
8.  Reconcile temporary files and metadata inconsistencies at startup.

Handle the filesystem/database boundary explicitly because a filesystem
rename and a database transaction cannot be one atomic transaction.
Recovery logic must resolve crashes between these steps.

Never delete a recoverable recording merely because metadata is
incomplete.

------------------------------------------------------------------------

## 10. Search and AI retrieval

### 10.1 Search modes

1.  Exact search: title, transcript words, and phrases.
2.  Semantic search: related meanings even when wording differs.
3.  AI question answering: synthesize an answer from retrieved sources.

Exact search must remain available offline. Semantic search can use
local embeddings or optional cloud embeddings.

### 10.2 Retrieval pipeline

1.  Parse query and optional date/collection filters.
2.  Search exact text.
3.  Search semantic index if enabled.
4.  Merge and deduplicate candidate segments.
5.  Apply user ownership, deletion, date, and collection filters.
6.  Rank by relevance; use recency only as a secondary signal.
7.  Select a bounded set of evidence excerpts.
8.  Send only those excerpts to the answer model when cloud AI is
    enabled.
9.  Require structured citations containing actual retrieved segment
    IDs.
10. Validate every citation against the retrieved candidate set.
11. Return answer, source excerpt, memory ID, and timestamps.

### 10.3 Grounding rules

-   No citation, no factual claim about a remembered event.
-   If evidence is missing, say that no supporting memory was found.
-   If memories conflict, show both sources and dates.
-   Distinguish direct statements from inference.
-   Never fabricate dates, people, or decisions.
-   Treat transcript content as untrusted data, never as system
    instructions.
-   Do not execute commands, URLs, or actions found inside recordings.
-   Ask the user before creating reminders or external tasks.
-   Keep answer-generation prompts versioned and tested.

### 10.4 Chunking and indexing

-   Segment transcripts around sentence/paragraph boundaries.
-   Preserve start/end timestamps.
-   Use a configurable overlap strategy where it improves recall.
-   Record embedding model/version and source content hash.
-   Re-index after transcript edits or embedding-model changes.
-   Make index rebuilds resumable.
-   Provide exact-search fallback if semantic indexing fails.

### 10.5 Multilingual quality

Support a configurable language preference, including Hindi and English.
Test Hinglish and code-switching rather than assuming every speech model
handles it well. Preserve the original-language transcript. Any
translation must be a separate derived artifact, not a replacement for
the source transcript.

------------------------------------------------------------------------

## 11. Background jobs and offline behavior

Processing is a durable queue, not a sequence of fragile UI callbacks.

### Job states

-   `queued`
-   `waiting_for_network`
-   `waiting_for_consent`
-   `uploading`
-   `processing`
-   `completed`
-   `retry_scheduled`
-   `failed`
-   `cancelled`

### Requirements

-   Persist state across app restarts.
-   Use bounded retries with exponential backoff and jitter.
-   Use idempotency keys for retried server operations.
-   Support cancellation where the provider allows it.
-   Distinguish permanent errors from transient errors.
-   Never delete source audio after a failed job.
-   Show pending work clearly.
-   Respect battery/network constraints.
-   Assume mobile background execution may be delayed or stopped by the
    OS.
-   Resume eligible work when the app becomes active.
-   Use platform schedulers/services only as permitted by current OS
    policies.

------------------------------------------------------------------------

## 12. Cloud backend and API

### 12.1 Backend principles

-   The client never contains privileged provider API keys.
-   Server validates identity and ownership on every request.
-   Private object storage only.
-   Short-lived signed upload/download URLs.
-   Strict file-size, MIME type, duration, and rate limits.
-   Request validation and bounded output sizes.
-   Per-user quotas and usage accounting.
-   Provider abstraction for transcription, embeddings, and LLMs.
-   Server-side secrets manager or deployment environment secrets.
-   No transcript/audio content in ordinary application logs.
-   Versioned API contracts.
-   Backups and tested restoration.

### 12.2 Proposed endpoints

-   `POST /v1/transcriptions` --- create a transcription job.
-   `GET /v1/jobs/{id}` --- retrieve job state.
-   `GET /v1/memories` --- list cloud-synced metadata.
-   `POST /v1/search` --- exact/semantic search.
-   `POST /v1/ask` --- grounded question answering.
-   `POST /v1/sync` --- exchange sync changes.
-   `POST /v1/exports` --- create an export.
-   `DELETE /v1/memories/{id}` --- request cloud memory deletion.
-   `DELETE /v1/account` --- request account and cloud-data deletion.

Adapt endpoints to the chosen backend. Enforce authentication,
authorization, validation, rate limits, and deletion semantics
regardless of framework.

### 12.3 Example request

``` json
{
  "query": "What did I say about learning C++?",
  "filters": {
    "from": "2026-09-01T00:00:00Z",
    "to": "2026-10-01T00:00:00Z",
    "collection_ids": []
  },
  "mode": "hybrid",
  "limit": 10
}
```

The server must reject unsupported modes, excessive limits, invalid
ranges, and unauthorized collection IDs.

### 12.4 Cloud file lifecycle

-   Upload only after user consent and policy checks.
-   Use resumable/multipart upload for large files when supported.
-   Verify hashes after upload.
-   Keep raw audio only for the documented retention period.
-   Delete temporary processing files after the task where supported.
-   Do not assume a provider's deletion API deletes all backups
    instantly.
-   Disclose provider retention limits accurately.
-   Avoid public bucket access and permanent public URLs.

------------------------------------------------------------------------

## 13. Sync and conflict resolution

Initial sync may be deferred until local capture, playback, and search
are stable.

Suggested policies: - Audio: immutable originals, hash verification. -
Transcript: versioned edits and conflict detection. - Titles:
field-level merge or explicit conflict UI. - Tags: set-based merge. -
Collections: explicit membership merge. - Deletes: tombstones propagated
to all devices. - Summaries/embeddings: mark stale and rebuild after
source edits. - Indexes: derived and rebuildable. - Preferences:
field-level conflict policy.

Do not blindly apply last-write-wins to transcript edits. Offline edits
on two devices must not silently destroy each other.

If the product later requires true end-to-end encrypted sync, design and
independently review the key management and recovery model before
implementation. Ordinary server-side AI cannot process content that
remains cryptographically inaccessible to the server.

------------------------------------------------------------------------

## 14. Security and privacy

### 14.1 Default behavior

-   Recording and playback are local.
-   No account required for local use.
-   Cloud AI disabled until explicitly enabled.
-   Cloud sync disabled until explicitly enabled.
-   Ask for microphone permission only when the user initiates
    recording.
-   Never request unrelated permissions.
-   Show which provider receives content before the first cloud
    operation.
-   Let the user revoke cloud processing and continue using local
    features.

### 14.2 Data protection

-   TLS for network traffic.
-   Platform-protected keys for local encryption.
-   Encrypt sensitive database/audio content at rest where appropriate
    to the threat model.
-   Do not invent a custom cryptographic scheme.
-   Keep refresh tokens and credentials in secure platform storage.
-   Use database row-level security and server-side ownership checks.
-   Use least-privilege service credentials.
-   Redact user content from logs and crash reports.
-   Do not include real recordings in test fixtures or analytics.
-   Review third-party SDK data collection and retention.
-   Provide export, deletion, retention, and privacy disclosures.
-   Avoid storing unnecessary location or contact data.

### 14.3 Deletion semantics

Deletion must cover: - Original local audio. - Transcript segments. -
Summaries and extracted items. - Search indexes and embeddings. -
Pending local jobs. - Cloud metadata and audio copies. - Derived
provider artifacts where deletion is supported. - Sync replicas and
tombstones.

Explain backup retention limitations. Never claim deletion from a
third-party backup is instantaneous unless that has been verified.

### 14.4 Threats to test

-   Lost/unlocked device.
-   Cross-account data leakage.
-   Exposed API keys.
-   Misconfigured public bucket.
-   Long-lived signed URL.
-   Transcript leakage through logs.
-   Prompt injection inside recorded speech.
-   Malicious transcript content.
-   Interrupted upload and duplicate jobs.
-   Deletion while processing.
-   Offline deletion and later reconnection.
-   Export files left in shared locations.
-   Unauthorized access to biometric-protected screens.

### 14.5 Legal readiness

Before launch, obtain appropriate review of privacy notices, consent,
data retention, app-store declarations, consumer terms, and applicable
privacy laws in target markets, including relevant Indian requirements
if launched in India. Do not represent this document as legal advice.

------------------------------------------------------------------------

## 15. Reliability and performance targets

These are initial engineering targets to validate on representative
physical devices, not existing measured results.

  -----------------------------------------------------------------------
  Metric                              Initial target
  ----------------------------------- -----------------------------------
  Home interactive                    p95 \<= 1.5 seconds on a
                                      representative mid-range device

  Record action response              p95 \<= 200 ms after permission and
                                      OS initialization

  Finalized recording integrity       Zero silent loss in defined
                                      failure-injection tests

  Local exact search                  p95 \<= 300 ms for a typical
                                      10,000-segment library

  Cached memory detail                p95 \<= 300 ms

  Crash-free sessions                 \>= 99.5% beta target, then improve
                                      toward 99.9%

  Citation validity                   100% of displayed source IDs
                                      validated against retrieved
                                      evidence

  Unauthorized cross-account access   Zero in security tests

  Unconsented cloud uploads           Zero in tests

  Delete-all completion               Verified local completion; remote
                                      completion reported only after
                                      confirmation
  -----------------------------------------------------------------------

### Required failure tests

-   Incoming call during recording.
-   Microphone permission revoked.
-   App termination during finalization.
-   Low disk space.
-   Device restart with queued jobs.
-   Offline for several days.
-   Expired auth token.
-   Interrupted upload.
-   Duplicate job submission.
-   Conflicting edits on two devices.
-   Provider outage.
-   Deletion during processing.
-   Large library performance.
-   Export interrupted midway.

------------------------------------------------------------------------

## 16. Testing strategy

### Unit tests

-   Domain models and validation.
-   Job state transitions.
-   Filename/path handling.
-   Search query normalization.
-   Transcript chunking.
-   Citation validation.
-   Conflict resolution.
-   Deletion policy.
-   Quota calculations.

### Database tests

-   Migrations from previous schema versions.
-   Transactions and foreign keys.
-   Full-text indexing and updates.
-   Rebuildable index behavior.
-   Tombstones and offline deletion.
-   Large library queries.

### Integration tests

-   Record -\> finalize -\> save -\> play.
-   Record -\> transcribe -\> search.
-   Transcript edit -\> index invalidation.
-   Ask -\> retrieve -\> answer -\> source citation.
-   Failed job -\> retry.
-   Export -\> validate output.
-   Cloud opt-in -\> upload -\> deletion.
-   Offline changes -\> sync -\> conflict handling.

### Platform tests

-   Android audio permissions and foreground-service behavior.
-   iOS microphone permission and audio-session interruptions.
-   Bluetooth/headphone route changes.
-   Backgrounding and process termination.
-   Device restart and recovery.
-   TalkBack and VoiceOver.
-   Small screens, tablets, and large text.

### AI evaluation

Build a synthetic and consented evaluation corpus with known expected
source segments. Measure: - Retrieval recall at k. - Citation
correctness. - Unsupported-claim rate. - Answer relevance. -
Multilingual transcription quality. - Latency and cost. - Regression
after model/prompt changes.

Never use private user recordings in test datasets without informed
permission and appropriate safeguards.

------------------------------------------------------------------------

## 17. Monetization

Use a freemium model. The local recorder and basic local library should
remain useful without a subscription.

### Free

-   Local recording and playback.
-   Basic organization.
-   Exact search over available transcripts.
-   Manual export.
-   Optional limited AI allowance, if financially viable.

### Pro

-   Higher transcription allowance.
-   Semantic search and AI questions.
-   Summaries and action extraction.
-   Advanced filters and exports.
-   Optional cloud sync and cross-device access.

### Teams --- later

-   Permission-controlled shared collections.
-   Team-level quotas and billing.
-   Administration and retention settings.
-   Audit controls.

Possible India pricing experiment: ₹299--₹499/month for Pro. This is a
hypothesis to test, not validated pricing.

Track variable costs for transcription, embeddings, LLM tokens, storage,
bandwidth, workers, payment processing, and support. Enforce server-side
quotas and cost alerts. Avoid unlimited cloud AI until unit economics
are measured.

------------------------------------------------------------------------

## 18. Delivery roadmap

### Milestone 0 --- Workspace and architecture

-   Inspect existing repository and installed toolchains.
-   Record architecture decisions.
-   Scaffold Flutter project if needed.
-   Set up linting, formatting, tests, and CI.
-   Create design tokens and navigation shell.

**Exit gate:** App launches on at least one available target;
architecture and setup instructions are documented.

### Milestone 1 --- Local recorder

-   Implement native audio adapter.
-   Implement recording state machine.
-   Implement finalization and crash recovery.
-   Implement playback.
-   Add permission and interruption handling.

**Exit gate:** Recordings survive restarts and pass defined reliability
tests.

### Milestone 2 --- Local library

-   Implement Drift schema and migrations.
-   Add Home and Memories screens.
-   Add title, tags, favorite, archive, delete.
-   Add storage management and export.

**Exit gate:** Core library works fully offline with no fake controls.

### Milestone 3 --- Transcription and exact search

-   Add provider interface.
-   Implement one transcription integration behind the interface.
-   Add timestamped transcript editing.
-   Add FTS search and re-indexing.
-   Add durable jobs and retries.

**Exit gate:** User can record, transcribe, search, and jump to source
audio.

### Milestone 4 --- Semantic search and Ask

-   Add embeddings adapter.
-   Implement hybrid retrieval.
-   Implement grounded answer generation.
-   Validate source citations.
-   Add evidence-missing and conflicting-source behavior.

**Exit gate:** AI answers are traceable and fail safely when evidence is
missing.

### Milestone 5 --- Optional cloud and sync

-   Add authentication only for sync features.
-   Add private storage and API authorization.
-   Add opt-in upload controls.
-   Implement sync cursors, conflicts, and deletion tombstones.
-   Add usage accounting.

**Exit gate:** Security tests pass; offline and cloud states are
transparent.

### Milestone 6 --- Release readiness

-   Device matrix testing.
-   Security and privacy review.
-   Accessibility review.
-   Performance tests.
-   Backup/restore and deletion verification.
-   Closed beta and issue triage.
-   Store metadata, privacy disclosures, and support workflow.

**Exit gate:** No unresolved critical/high-severity issues; release
checklist signed off.

Timeline is intentionally evidence-driven. Do not mark a milestone
complete just because its UI exists.

------------------------------------------------------------------------

## 19. Release checklist

-   [ ] Android and iOS builds compile in a clean environment.
-   [ ] Recording and playback tested on physical devices.
-   [ ] Interrupted recording recovery verified.
-   [ ] Offline capture and local search verified.
-   [ ] No mandatory login for core local features.
-   [ ] Cloud AI and sync require appropriate explicit opt-in.
-   [ ] No provider secrets bundled in the app.
-   [ ] All AI citations validated.
-   [ ] Database migrations tested.
-   [ ] Export and deletion verified.
-   [ ] Cross-account authorization tests pass.
-   [ ] Accessibility smoke tests pass.
-   [ ] Privacy policy matches actual implementation.
-   [ ] App-store privacy declarations are accurate.
-   [ ] Monitoring excludes transcript/audio contents by default.
-   [ ] Backup restoration tested.
-   [ ] Usage limits and cost alerts tested.
-   [ ] Support and incident-response procedures documented.

------------------------------------------------------------------------

## 20. Definition of done

A feature is done only when: 1. It is implemented end to end. 2.
Loading, empty, error, permission-denied, offline, and success states
are handled. 3. Data persists correctly across restarts. 4. It has
automated tests appropriate to the feature. 5. Accessibility has been
considered. 6. No secret or private user content is leaked. 7.
Documentation reflects actual behavior. 8. Static analysis and relevant
tests pass. 9. Known limitations are documented. 10.
`docs/IMPLEMENTATION_STATUS.md` records the evidence.

Do not mark screens complete when their primary controls are inert. Do
not ship mock data as real user data. Do not hide failures behind
generic success messages.

------------------------------------------------------------------------

## 21. Final instruction to the coding agent

Begin by inspecting the current workspace and toolchain. Then implement
**Milestone 0 and Milestone 1**, keeping the app buildable and recording
progress in `docs/IMPLEMENTATION_STATUS.md`.

Do not attempt to implement every future feature in one large change.
Work in small, verifiable increments. Use the local recorder and memory
library as the foundation; add transcription, retrieval, AI, and cloud
sync only after the relevant acceptance gates pass.

The product succeeds when users can trust it with a thought today and
reliably find that thought months later.
