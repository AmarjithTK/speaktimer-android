# SolasFlow / SpeakTimer Improvement Plan

## Overview

This plan covers 10 improvement areas split into two buckets. Bucket A contains quick-win UI/UX improvements. Bucket B contains deep technical reliability review.

---

## Bucket A — Quick Wins (Target: Same Day)

### A1. Merge TTS Volume Features
**Priority: MEDIUM**

**Problem:** Two separate toggles — "TTS Volume Boost" and "TTS Max Device Volume Lock" — solve the same user problem (speech too quiet).

**Solution:** Replace both with single "Maximum Speech Volume" control.
- Remove `ttsVolumeBoostEnabled` and `ttsMaxVolumeLockEnabled` state variables
- Add single `maximumSpeechVolume` boolean state variable
- Behavior: When ON, apply both boost AND max volume lock simultaneously
- Add migration in [`SettingsService`](lib/services/settings_service.dart) (schema version 8)

**Files to modify:**
- [`lib/core/pref_keys.dart`](lib/core/pref_keys.dart) — add `maximumSpeechVolume`, remove old keys
- [`lib/models/app_settings.dart`](lib/models/app_settings.dart) — replace fields
- [`lib/services/settings_service.dart`](lib/services/settings_service.dart) — load/save/migrate new field
- [`lib/services/speech_service.dart`](lib/services/speech_service.dart) — update `speakItem()` to use single combined logic
- [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart) — replace two switches with one
- [`lib/main.dart`](lib/main.dart) — update all references in state, `_initPrefs()`, `_currentSettingsSnapshot()`, `drainQueue()`, `speakItem()` call

---

### A2. Settings Cleanup
**Priority: HIGH**

**Problem:** Settings feels crowded. Different sections compete visually. Goal section feels disconnected.

**Solution:** Reorganize into 6 logical groups:

| Section | Controls |
|---------|----------|
| **Audio & Speech** | Background sound, Noise volume, Speech volume, Maximum Speech Volume (merged toggle) |
| **Voice** | Speech engine, Engine status, Language list, Voice selection |
| **Focus & Fullscreen** | App font size, Dark fullscreen, Dim brightness, Landscape start |
| **Sleep Mode** | Enable sleep mode, Mode (manual/auto), Start time, End time |
| **Goals** | Manage Goals button |
| **System** | Auto-start (accessibility), About/Help links |

**Files to modify:**
- [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart) — reorder sections, update section titles and icons

---

### A3. Unify Clock / Timer / Stopwatch Card Layout
**Priority: HIGH**

**Problem:** Clock uses gradient card, Timer uses circular ring painter, Stopwatch uses border-only container. Three different visual languages.

**Solution:** Use the same card pattern everywhere:

**Clock** (keep current — it's the reference design):
- Gradient primary-colored card
- "CURRENT TIME" label
- Large time display
- "Tap for fullscreen" hint

**Timer** (replace circular ring):
- Same gradient card as Clock
- "REMAINING TIME" label
- Large MM:SS display
- "Ends at X:XX PM" status text (move ring to fullscreen only)

**Stopwatch** (upgrade container):
- Same gradient card as Clock
- "ELAPSED TIME" label
- Large elapsed display
- Unit labels (hr/min/sec/ms) row

**Files to modify:**
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart) — replace `_timerCircle()` with new `_timeCard()` using gradient
- [`lib/widgets/stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart) — replace `_elapsedCard()` with gradient card matching Clock
- [`lib/widgets/clock_panel.dart`](lib/widgets/clock_panel.dart) — minor adjustments if needed

---

### A4. Make Timer the Default Landing Tab
**Priority: HIGH**

**Problem:** App opens to Speaking Clock, but Timer provides more interaction and utility.

**Solution:** Change default tab index from 0 (Clock) to 1 (Timer).

**Files to modify:**
- [`lib/main.dart`](lib/main.dart) — change `currentTabIndex = 0` to `currentTabIndex = 1` in initial declaration

---

### A5. Global Speech Master Toggle
**Priority: HIGH**

**Problem:** Users must individually disable clock, timer, stopwatch, and goal speech. No single "stop talking" control.

**Solution:** Add one global `speechMasterOn` toggle that suppresses ALL speech when OFF.

**Behavior:**
- OFF = temporarily suppress all speech (clock, timer, stopwatch, goal reminders)
- ON = restore existing per-feature settings (existing on/off states preserved)
- Existing individual toggles remain unchanged and functional

**Access points:**
1. Persistent notification button
2. Home screen widget button
3. Main app UI — prominent toggle

**Implementation approach:**
- The existing [`_isSpeechMutedForSleep()`](lib/main.dart:1968) method already gates ALL speech paths. Adding a `!speechMasterOn` check there provides instant global gating with zero changes to individual speech paths.
- New notification button added to [`ForegroundNotificationState`](lib/models/foreground_notification_state.dart) buttons list
- New widget action handled in [`_handleWidgetAction()`](lib/main.dart:1370)

**Files to modify:**
- [`lib/core/pref_keys.dart`](lib/core/pref_keys.dart) — add `speechMasterOn` key
- [`lib/models/app_settings.dart`](lib/models/app_settings.dart) — add field
- [`lib/models/foreground_notification_state.dart`](lib/models/foreground_notification_state.dart) — add button
- [`lib/services/settings_service.dart`](lib/services/settings_service.dart) — load/save
- [`lib/main.dart`](lib/main.dart) — add state, modify `_isSpeechMutedForSleep()`, handle notification/widget actions, add UI toggle
- [`lib/widgets/clock_panel.dart`](lib/widgets/clock_panel.dart) — if showing toggle in clock panel
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart) — if showing toggle in timer panel

---

### Implementation Order (Recommended)

```
Step 1: A1 — Merge TTS Volume Features  (model + service changes)
Step 2: A2 — Settings Cleanup            (UI reorganization)
Step 3: A3 — Unified Card Layout        (panel visual changes)
Step 4: A4 — Timer Default Tab          (single-line change)
Step 5: A5 — Global Speech Toggle       (new feature with multiple touchpoints)
```

Steps 1-2 interact (settings panel), steps 3-5 are independent.

---

## Bucket B — Deep Technical Review (Future Session)

### B1. Sleep Mode Verification
**Priority: HIGH**
- Time window handling
- Midnight crossing
- Auto mute
- Resume behavior
- Verify reliability

### B2. Reliability Audit
**Priority: VERY HIGH**
- Foreground service persistence
- Boot recovery
- Accessibility integration
- Background execution
- Speech scheduling correctness
- Notification controls
- Battery optimization handling
- Race conditions in speech queue
- Long session stability

### B3. Announcement Speech Quality
**Priority: MEDIUM**
- Review English announcements
- Review Malayalam announcements
- Goal reminders
- Timer completion
- Countdown announcements

### B4. Goal Section Review
**Priority: MEDIUM**
- Better organization within Settings
- Better visual integration
- Better editing experience

### B5. Voice Auto-Selection
**Priority: LOW**
- Verify auto-selection works reliably per language
- Only modify if currently broken
