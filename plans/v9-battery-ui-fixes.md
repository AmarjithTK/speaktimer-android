# SolasFlow v9 — Battery, UI & Widget Fixes

## Issues

1. **Background persistence toggle** — App drains 13% battery/hour because foreground service runs after a single morning open. Need a toggle on the Clock screen to enable/disable background running. Default: OFF.
2. **Clock patch missing from widget-triggered timers** — When a timer is started from the home screen widget, the small clock patch at the bottom of the fullscreen timer view doesn't appear. Works fine when triggered from inside the app.
3. **TimerRing stroke too thin** — The circular progress ring stroke width is too thin. Needs to be bolder. Also the clock patch border in fullscreen view needs more stroke width.
4. **Pause button UI not updating** — When pausing a timer, the button stays as "Pause" instead of switching to "Start" until the user navigates away and comes back.

---

## Plan

### 1. Background Persistence Toggle

**Root cause:** [`_initializeForegroundNotification()`](lib/main.dart:749) runs unconditionally on app start, starting the foreground service. The health-check loop also re-starts it.

**Fix:**
- Add a new persisted setting `backgroundPersistenceOn` (default: `false`) to [`AppSettings`](lib/models/app_settings.dart:1) and [`SettingsService`](lib/services/settings_service.dart)
- Add a toggle on the Clock screen (in [`ClockPanel`](lib/widgets/clock_panel.dart:10)) — a new `_FeatureToggle` row item labeled "Background" with a shield/keep-alive icon
- Gate [`_initializeForegroundNotification()`](lib/main.dart:749) behind this setting — only call it when `backgroundPersistenceOn` is `true`
- Gate the health-check foreground service re-launch (line ~762) behind this setting too
- When the toggle is turned ON, start the foreground service; when OFF, stop it via `FlutterForegroundTask.stopService()`
- The foreground service for active timers (called in [`startTimer()`](lib/main.dart:3014)) should still work regardless of this toggle — the toggle only controls the idle/background persistence

**Files to modify:**
- [`lib/models/app_settings.dart`](lib/models/app_settings.dart) — add field
- [`lib/services/settings_service.dart`](lib/services/settings_service.dart) — add persistence
- [`lib/main.dart`](lib/main.dart) — gate foreground init, add toggle state + handler, add Clock tab toggle
- [`lib/widgets/clock_panel.dart`](lib/widgets/clock_panel.dart) — add toggle UI

### 2. Clock Patch Missing from Widget-Triggered Timers

**Root cause:** When the widget triggers a timer via [`_handleWidgetAction()`](lib/main.dart:1698), it calls [`_openFullscreenFocus()`](lib/main.dart:1274) which passes `initialShowClock: fullscreenShowClock`. The `fullscreenShowClock` setting defaults to `false` (line 526). On a cold start from the widget, the settings load may not have completed by the time the widget action is processed, so `fullscreenShowClock` is still `false`.

Additionally, even if settings are loaded, the user may not have explicitly toggled `fullscreenShowClock` on — the widget path doesn't ensure it.

**Fix:**
- In [`_handleWidgetAction()`](lib/main.dart:1698), when processing `start_Xm` preset actions, explicitly set `fullscreenShowClock = true` before calling `_openFullscreenFocus()`. This ensures the clock patch always shows when a timer is triggered from the widget.
- Alternatively (cleaner): Read `fullscreenShowClock` from SharedPreferences directly in the widget action handler if the in-memory value is still default.

**Files to modify:**
- [`lib/main.dart`](lib/main.dart) — ensure `fullscreenShowClock = true` in widget timer trigger path

### 3. TimerRing & Clock Patch Border Thickness

**Root cause:** 
- [`TimerRing`](lib/widgets/timer_ring.dart:53) uses `strokeWidth = math.max(size.width * 0.022, 3.0)` — too thin
- Clock patch in [`FullscreenFocusView`](lib/widgets/fullscreen_focus_view.dart:497) uses `Border.all(color: outline, width: 1)` — too thin

**Fix:**
- Increase TimerRing stroke multiplier from `0.022` to `0.04` (roughly doubles the thickness)
- Increase clock patch border width from `1` to `2.5` or `3`

**Files to modify:**
- [`lib/widgets/timer_ring.dart`](lib/widgets/timer_ring.dart) — increase stroke multiplier
- [`lib/widgets/fullscreen_focus_view.dart`](lib/widgets/fullscreen_focus_view.dart) — increase clock patch border width

### 4. Pause Button UI Not Updating

**Root cause:** [`stopTimer()`](lib/main.dart:3052) sets `timerInterval = null` but does NOT call `setState()`. Since [`TimerPanel`](lib/widgets/timer_panel.dart:303) reads `isRunning: timerInterval != null`, the UI never rebuilds to show "Start" instead of "Pause".

**Fix:**
- Wrap `timerInterval = null` in a `setState()` call inside [`stopTimer()`](lib/main.dart:3052)

**Files to modify:**
- [`lib/main.dart`](lib/main.dart) — add `setState()` to `stopTimer()`

---

## Execution Order

1. Fix pause button UI (smallest, safest change)
2. Fix TimerRing & clock patch border thickness
3. Fix clock patch missing from widget-triggered timers
4. Add background persistence toggle (largest change, touches multiple files)
