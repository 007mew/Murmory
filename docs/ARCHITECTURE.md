# Murmory Architecture Specification

## Overview

Murmory is an offline-first, private voice memory system built on Flutter (Dart) for Android and iOS. Its primary function is rapid, zero-latency thought capture, persistent immutable local audio preservation, high-fidelity local relational querying via Drift (SQLite), and optional on-device/cloud transcription and grounded AI retrieval.

## System Topology

```
┌────────────────────────────────────────────────────────┐
│                   Murmory Mobile Client                │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │                    UI Layer                      │  │
│  │  Home  │  Recording  │  Memories  │  Ask  │ Config │  │
│  └─────────────────────────┬────────────────────────┘  │
│                            │                           │
│  ┌─────────────────────────▼────────────────────────┐  │
│  │             State Management (Riverpod)           │  │
│  │  RecordingNotifier │ MemoryListNotifier │ Ask... │  │
│  └─────────────┬───────────────────────────┬────────┘  │
│                │                           │           │
│  ┌─────────────▼──────────┐ ┌──────────────▼────────┐  │
│  │    Audio Engine (IO)    │ │   Repositories Domain │  │
│  │  RecordService (AAC)   │ │   MemoryRepository    │  │
│  │  PlayerService (Local) │ │   SearchRepository    │  │
│  └─────────────┬──────────┘ └──────────────┬────────┘  │
│                │                           │           │
│  ┌─────────────▼───────────────────────────▼────────┐  │
│  │               Persistence & Recovery             │  │
│  │  App Filesystem (AAC)   │ Drift (SQLite + FTS5)  │  │
│  └──────────────────────────────────────────────────┘  │
└───────────────────────────┬────────────────────────────┘
                            │ (Optional / Opt-in)
┌───────────────────────────▼────────────────────────────┐
│              Optional Cloud Sync & Inference           │
│         Supabase / PostgreSQL & Whisper/LLM API        │
└────────────────────────────────────────────────────────┘
```

## Architectural Tenets

1. **Local-First & Accountless:** Core capture, cataloging, playback, and exact search function with zero network access and require no account creation.
2. **Immutable Audio:** Recorded audio files are finalized, SHA-256 hashed, and never mutated or deleted by background processes unless explicitly requested by the user.
3. **Reactive Unidirectional Data Flow:** State is managed via Riverpod controllers, exposing immutable state models to declarative Flutter widgets.
4. **Crash Recovery & Reconciliation:** Every recorded segment writes to a sandboxed temporary file. In the event of process termination, startup reconciliation scans for abandoned files and promotes them to valid memory records.
5. **Fluid Motion & Responsiveness:** UI interactions target 60/120fps with immediate audio capture initialization (<200ms) upon button tap.
