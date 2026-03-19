# lifer

`lifer` is a Flutter focus app that combines a speaking clock, a configurable timer, and an immersive fullscreen focus mode.

## What it does

### Speaking Clock
- Shows a live digital clock with large, readable typography.
- Speaks the current time at a configurable interval (`1, 2, 5, 10, 15, 20, 30, 60` minutes).
- Optional motivational quote after each spoken time.
- Quote category options:
	- `General`
	- `Focus`
	- `Discipline`
	- `Calm`
	- `Positivity`
	- `Historic Figures`
- Motivation delay options (`5, 10, 20, 30, 40, 60` seconds).

### Timer
- Adjustable duration (`1` to `120` minutes).
- Quick preset values include `5, 10, 15, 20, 25, 30, 45, 60, 90, 120`.
- Start / Stop / Reset controls.
- Optional background noise playback while timer runs.
- Optional spoken remaining time, configurable cadence (`1, 2, 5, 10, 15, 20, 30` minutes).
- Chain timer mode with built-in presets:
	- `Pomodoro 25-5x4`
	- `Sprint 50-10x2`
	- `Quick 15-3x3`

### Fullscreen Focus mode
- Dedicated fullscreen screen for clock/timer focus.
- Auto-hides controls after 5 seconds; tap anywhere to toggle controls.
- Immersive state increases visual emphasis of time display.
- In-view controls:
	- Always-on screen toggle (wakelock)
	- Dark/light theme toggle
	- Dim brightness toggle
	- Rotate horizontal / unlock rotation toggle
	- Switch between `SpeakClock` and `Timer` views
- Fullscreen defaults are configurable from settings:
	- Use dark theme by default
	- Dim screen brightness in fullscreen
	- Start fullscreen in horizontal orientation

### Notification + background behavior
- Foreground service keeps timer/clock state alive in background.
- Notification buttons can control timer and clock speech state.
- App provides full-exit behavior that stops timer/clock/audio and foreground service.

### Voice and audio settings
- Nature sound selection (local bundled assets).
- Separate noise volume and speech volume controls.
- Voice list mode (`pleasant` vs `all` English voices).
- Favorite voice selection.

### Quick Actions (launcher shortcuts)
- `Start 25m`
- `Resume Last`
- `Toggle Speech`

### Persistence
- Preferences are persisted with `shared_preferences`, including:
	- sound + volume choices
	- clock interval + motivation settings
	- timer speech/noise settings
	- fullscreen defaults
	- voice preferences

## Tech stack

- Flutter / Dart
- `flutter_tts`
- `audioplayers`
- `flutter_foreground_task`
- `flutter_local_notifications`
- `quick_actions`
- `wakelock_plus`
- `screen_brightness`
- `shared_preferences`

## Project structure (important paths)

- `lib/main.dart` — app orchestration, tabs, state, lifecycle
- `lib/widgets/clock_panel.dart` — speaking clock UI
- `lib/widgets/timer_panel.dart` — timer + chain timer UI
- `lib/widgets/fullscreen_focus_view.dart` — fullscreen focus mode
- `lib/widgets/settings_panel.dart` — settings UI
- `lib/services/settings_service.dart` — settings persistence
- `lib/models/app_settings.dart` — settings model
- `lib/core/pref_keys.dart` — preference keys
- `assets/audio/` — bundled local audio files

## Getting started

### Prerequisites
- Flutter SDK installed
- Dart SDK compatible with this project (`sdk: ^3.11.3`)
- Android Studio / Xcode (for mobile builds)

### Install dependencies
```bash
flutter pub get
```

### Run
```bash
flutter run
```

### Test
```bash
flutter test
```

## Notes

- App display name is `lifer`.
- Android package namespace and notification metadata still use `com.example.speakertimer` in platform config for compatibility.
- Audio assets are local (`assets/audio/`) to support offline/background behavior.
