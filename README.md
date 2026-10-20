# Murmory

**Speak it. Find it.**

Murmory is a private, searchable personal voice memory application for Android and iOS. Capture thoughts by speaking them. Find them again whenever you need them.

## What it is

Murmory is not a general voice recorder or meeting bot. It is a personal memory system built around voice. You record a thought in seconds, the original audio stays on your device, and you can later search across all your recordings to retrieve a specific detail.

**Core promise:** Capture a thought once. Find it whenever you need it.

## Stack

| Layer | Technology |
|---|---|
| UI & platform | Flutter 3.x + Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| Local database | Drift + SQLite (FTS5) |
| Audio recording | `record` package |
| Audio playback | `just_audio` |
| Backend (optional) | Supabase / PostgreSQL |

## Project layout

```
murmory/
├── apps/
│   └── mobile/          # Flutter app (Android + iOS)
├── backend/             # Optional cloud API
├── docs/                # Architecture, data model, security, decisions
└── scripts/             # Build and utility scripts
```

## Getting started

### Prerequisites

- Flutter 3.32+ (stable)
- Dart 3.4+
- Android SDK 35 (for Android builds)
- Xcode 16+ (for iOS builds, macOS only)
- Java 17+ (for Android builds)

### Setup

```bash
cd apps/mobile
flutter pub get
flutter run
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for detailed architecture documentation.
See [`docs/IMPLEMENTATION_STATUS.md`](docs/IMPLEMENTATION_STATUS.md) for current progress.

## Privacy

Local recording and playback work without an account and without any network connection. Cloud AI features are optional and disabled by default. See [`docs/SECURITY.md`](docs/SECURITY.md).

## License

Private — not yet licensed for distribution. Contact the repository owner.
