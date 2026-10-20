# Murmory Decisions Log

## 001 - Mobile Stack Selection: Flutter + Drift + Riverpod
- **Context:** Murmory requires high-performance, fluid UI across Android and iOS with native audio control, offline-first SQLite access, and FTS5 search.
- **Decision:** Use Flutter 3.x with Riverpod 2.x for reactive state management and Drift for strongly-typed SQLite and FTS5 support.
- **Consequences:** Single cross-platform codebase, unified design language, deterministic offline storage, and excellent Dart asynchronous audio capabilities.

## 002 - Audio Container & Encoding: AAC-LC in MP4 / M4A
- **Context:** Cross-platform audio capture must balance compression, low battery impact, low latency, and broad decoder compatibility across Android and iOS.
- **Decision:** Encode audio using AAC-LC in `.m4a` format at 64–128kbps, 44.1kHz / 48kHz mono.
- **Consequences:** Efficient compression (~1MB per 2-3 minutes), native hardware encoding support on all target Android/iOS versions, direct compatibility with transcription APIs (Whisper/Gemini).

## 003 - Offline-First Local Storage Architecture
- **Context:** Users capture thoughts in elevators, subways, or offline mode. Network reliance during capture causes friction and lost thoughts.
- **Decision:** Audio is saved to app storage and metadata is committed to SQLite before any background or network operation is considered.
- **Consequences:** 100% reliable capture; zero risk of losing voice notes due to poor network connectivity.
