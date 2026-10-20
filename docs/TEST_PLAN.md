# Murmory Test Plan

## Core Verification Suites

### 1. Audio Recording & Interruption Suite
- **Normal Lifecycle:** Start -> Pause -> Resume -> Stop -> Commit. Verify audio duration matches recorded time within 100ms tolerance.
- **Interruption Resilience:** Test phone call incoming during active capture. Validate that recorder safely flushes buffered frames or pauses gracefully without losing previous audio.
- **Microphone Denied:** Test user denying audio permission. Verify calm contextual explanation, non-blocking UI, and settings link.
- **Low Storage Recovery:** Simulate disk full. Ensure temporary file preservation and descriptive error display.

### 2. Local Database & FTS5 Search Suite
- **CRUD Operations:** Insert memories, update titles, toggle favorites, soft delete and hard delete.
- **FTS5 Exact Matching:** Verify searching terms like "quarterly meeting" highlights and pinpoints segments within <300ms across 10,000+ entries.
- **Cascade Deletion:** Verify deleting a memory cascades to its transcript segments and associated tags.

### 3. Responsiveness & UI Fluidity Suite
- **Interaction Target:** Home screen tap-to-record responsiveness < 200ms.
- **Frame Rate:** Maintain smooth 60fps/120fps transitions using optimized `ListView.builder` widgets and const constructors.
