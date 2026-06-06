# Speech Language System — Redesign Plan

## Current State

The app has `voiceListMode` (auto/english/malayalam) that filters voices but doesn't control speech content reliably. `MalayalamTtsService` provides Malayalam text for clock/timer/stopwatch announcements. English uses `TimerService.timeToWords()`.

## Proposed Architecture

### 1. Speech Language Service (`lib/services/speech_language_service.dart`)
A centralized service that:
- Stores the active language (`speechLanguage`: english/malayalam/hindi)
- Filters voices to only show those matching the language
- Auto-selects a suitable voice when language changes
- Provides language-specific text for all announcement types

### 2. Language-Specific Announcement Providers
Each language has its own class providing text:
- `EnglishAnnouncements` — existing `TimerService.timeToWords()` logic
- `MalayalamAnnouncements` — existing `MalayalamTtsService`
- `HindiAnnouncements` — NEW, comparable structure

Each provides:
- `clockAnnouncement(DateTime)` → spoken time text
- `timerRemaining(int minutes)` → "X minutes remaining"
- `timerFinished()` → "Timer finished"
- `stopwatchElapsed(int seconds)` → "Elapsed X minutes"
- `quoteForCategory(String)` → motivational quote

### 3. Language as Single Source of Truth
When language changes:
1. Voice list filters to only that language's voices
2. If current voice doesn't match, auto-select best match
3. All future speech uses the language's announcement provider
4. `VoiceSessionManager` resets cache

### 4. Files to Change
| File | Change |
|------|--------|
| `lib/services/speech_language_service.dart` | **NEW** — language management, announcement dispatch |
| `lib/services/malayalam_tts_service.dart` | Rename to `malayalam_announcements.dart`, keep Malayalam text |
| `lib/services/timer_service.dart` | Extract `timeToWords` into new `english_announcements.dart` |
| `lib/services/hindi_announcements.dart` | **NEW** — Hindi text |
| `lib/main.dart` | Replace `voiceListMode` with `speechLanguage`, use service |
| `lib/widgets/settings_panel.dart` | Language picker shows supported languages |
| `lib/services/voice_session_manager.dart` | Already handles caching, update for new language model |
| `lib/services/speech_service.dart` | Voice filtering uses language instead of mode |
