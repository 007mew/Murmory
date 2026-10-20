# Murmory — Mobile App

> Speak it. Find it. — Private searchable voice memory.

## Getting Started

### Prerequisites

- Flutter 3.x (`flutter --version`)
- Android Studio or VS Code with Flutter extension
- Android SDK (for Android) or Xcode (for iOS)

### Setup

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Architecture

- **State Management**: Riverpod (flutter_riverpod + riverpod_annotation)
- **Navigation**: GoRouter
- **Database**: Drift + SQLite with FTS5
- **Audio Recording**: `record` package
- **Audio Playback**: `just_audio`

### Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart          # MurmoryApp root widget
│   └── router.dart       # GoRouter configuration
├── core/
│   ├── audio/            # Recording & playback services
│   ├── database/         # Drift DB, tables, DAOs
│   ├── design_system/    # Tokens, themes, shared widgets
│   ├── files/            # Audio file management
│   ├── providers/        # Global Riverpod providers
│   └── repositories/     # Data access layer
└── features/
    ├── ask/              # AI Q&A screen
    ├── home/             # Home screen
    ├── memories/         # Memories library
    ├── memory_detail/    # Memory detail + player
    ├── recording/        # Recording studio
    ├── search/           # Full-text search
    └── settings/         # App settings
```
