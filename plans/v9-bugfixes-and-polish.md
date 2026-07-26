# SolasFlow v9 — Bug Fixes, Polish & Consistency

## Status: PLANNING

---

## Issue 1: Notification Priority Conflict with ThoughtFlow

**Problem:** SolasFlow and ThoughtFlow notifications compete for the top spot in the notification drawer because neither sets explicit notification importance/priority.

**Root Cause:** [`ForegroundNotificationService`](lib/services/foreground_notification_service.dart:7) uses `FlutterForegroundTask.startService()` without specifying notification channel importance. The default is `IMPORTANCE_DEFAULT` which causes both apps to compete for position.

**Fix:**
- Set notification importance to `IMPORTANCE_LOW` (persistent, no sound/vibrate, stays in drawer but doesn't pop up) or `IMPORTANCE_DEFAULT` with a unique channel ID
- In [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml:24), add a notification channel with `android:importance="low"` for the foreground service
- Use `FlutterForegroundTask.init()` with proper notification channel config if the package supports it
- Alternatively, set `notificationPriority` in the `FlutterForegroundTask.updateService()` call

**Files to modify:**
- [`lib/services/foreground_notification_service.dart`](lib/services/foreground_notification_service.dart)
- [`lib/main.dart`](lib/main.dart) (init call)
- [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)

---

## Issue 2: Premium Animations & Transitions

**Problem:** Current transitions are basic — 220ms fade+slide on tab switch, no animation on bottom nav, no page transitions.

**Fix:**
- Upgrade tab transition to smooth 350ms+ with `Curves.easeOutQuart` or `Curves.easeInOutCubic`
- Add animated indicator on `BottomNavBar` (smooth slide instead of instant jump)
- Add `Hero` animations for shared elements (timer display, clock display)
- Add subtle scale/fade on button presses
- Add `AnimatedContainer` for toggle states
- Add smooth `AnimatedOpacity` / `AnimatedScale` for conditional UI elements
- Consider adding `PageTransitionSwitcher` or custom `PageTransitionsBuilder`

**Files to modify:**
- [`lib/main.dart`](lib/main.dart) (AnimatedSwitcher config)
- [`lib/widgets/bottom_nav_bar.dart`](lib/widgets/bottom_nav_bar.dart)
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart)
- [`lib/widgets/clock_panel.dart`](lib/widgets/clock_panel.dart)
- [`lib/widgets/stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart)
- [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart)
- [`lib/widgets/primary_button.dart`](lib/widgets/primary_button.dart)
- [`lib/widgets/secondary_button.dart`](lib/widgets/secondary_button.dart)

---

## Issue 3: +5 Min Timer Bug — Shows 15:00 Instead of 14:58

**Problem:** When timer is at 9:58 and user taps "+5 min", it shows 15:00 instead of 14:58.

**Root Cause:** In [`timer_panel.dart:300`](lib/widgets/timer_panel.dart:300), the +5 min button calls `choosePreset((sliderValue + 5).clamp(1, 720))`. The [`choosePreset()`](lib/main.dart:3044) function resets the timer (`resetTimer()` + `startTimer()`), setting `seconds = sliderValue * 60`. So adding 5 to `sliderValue` (10 → 15) resets to exactly 15:00, discarding the 2 seconds of progress.

**Fix:**
- When running, "+5 min" should add 300 to `seconds` (remaining seconds) directly, NOT reset the timer
- Create a new `_addTimeToRunningTimer(int additionalSeconds)` method in `_MainScreenState`
- Same for "-1 min" — should subtract from remaining seconds, not reset
- Only use `choosePreset()` for the idle state buttons

**Files to modify:**
- [`lib/main.dart`](lib/main.dart) (add `_addTimeToRunningTimer` method)
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart:298) (wire up new callback)

---

## Issue 4: Timer Remaining Time Font Too Small in Non-Fullscreen Mode

**Problem:** When timer is running with the ring, the remaining time font is 40px ([`timer_panel.dart:172`](lib/widgets/timer_panel.dart:172)), which is too small.

**Fix:**
- Increase running-state font size from 40px to 52-56px
- Ensure `FittedBox` is used to prevent overflow on small screens
- Match the idle state's visual weight (64px with FittedBox)

**Files to modify:**
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart:172)

---

## Issue 5: Settings Export Saves to Cache Folder

**Problem:** [`exportToTempFile()`](lib/services/settings_service.dart:338) uses `getTemporaryDirectory()` which returns the app's cache folder (`/data/data/com.atherpulse.solasflow/cache/`). This is hard to find and can be cleaned by the OS.

**Fix:**
- Use `file_picker` with `directory` mode to let user choose save location
- OR save to user-accessible location like `Downloads/SolasFlow/`
- Rename file from `solasflow_backup_<timestamp>.json` to `SolasFlow_Settings_<YYYY-MM-DD_HHmm>.json`
- Show a `Share` or `Save to folder` dialog instead of just displaying the path

**Files to modify:**
- [`lib/services/settings_service.dart`](lib/services/settings_service.dart:338)
- [`lib/main.dart`](lib/main.dart:1107) (`_handleBackupSettings`)

---

## Issue 6: Poor State Management — Toggles Don't Update Reactively

**Problem:** Toggles in settings don't reflect immediately; user must navigate back and re-enter the screen for widgets to rebuild. The app uses 91+ `setState()` calls in a single `_MainScreenState`. `SettingsPanel` is pushed via `Navigator.push` so `didUpdateWidget` never fires for route-based panels.

**Root Cause:** 
- [`SettingsPanel`](lib/widgets/settings_panel.dart:110) maintains local state (`_soundChosen`, `_noiseVolume`, etc.) copied from props in `initState()`
- When opened via `Navigator.push` ([`_openSettings()`](lib/main.dart:1093)), it's a separate route — parent rebuilds don't propagate to it
- The panel's local `setState()` updates its own UI but doesn't sync back to parent unless explicitly saved

**Fix (Minimal — Provider approach):**
- Add `provider` package (or use existing `ValueNotifier` pattern)
- Create a `SettingsState` class extending `ChangeNotifier` (or `ValueNotifier`)
- Move all settings state from `_MainScreenState` fields into `SettingsState`
- Wrap app with `ChangeNotifierProvider<SettingsState>`
- `SettingsPanel` reads from provider instead of maintaining local copies
- Toggles immediately reflect across all screens

**Alternative (Lighter — fix the Navigator.push issue):**
- Make `_openSettings()` use a `showModalBottomSheet` or `showGeneralDialog` with `maintainState: true` instead of `Navigator.push`
- Or pass a `ValueNotifier<AppSettings>` to the settings panel

**Files to modify:**
- [`pubspec.yaml`](pubspec.yaml) (add `provider` if chosen)
- [`lib/main.dart`](lib/main.dart) (refactor state, wrap with provider)
- [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart) (read from provider)
- New file: `lib/providers/settings_state.dart` (if Provider approach)

---

## Issue 7: Timer Screen — Two Buttons Stacked Vertically

**Problem:** Timer main screen has Start/Pause as a full-width button, then Reset + "+5 min" stacked below. User wants them on one line.

**Fix:**
- Combine into a single row: [Reset] [Start/Pause] [+5 min]
- Or: [Reset] [-1 min] [Start/Pause] [+5 min] (when running)
- Reduce font size slightly to fit one line
- Use `CompactPrimaryButton` or adjust `PrimaryButton`/`SecondaryButton` to be more compact

**Files to modify:**
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart:276)

---

## Issue 8: UI Consistency — Time Display Across Clock/Timer/Stopwatch

**Problem:** Three panels show time differently:
- Clock: `DisplayText` widget directly, no card container, large font
- Timer: Inside a `Container` with surface color + border + rounded corners
- Stopwatch: Inside a `Container` with surface color + border + rounded corners (like timer)

**Fix:**
- Standardize all three to use the same `DisplayText` widget with the same container treatment
- Use identical: container padding, border radius, font size, label style, FittedBox wrapping
- Create a shared `TimeDisplayCard` widget that all three panels use
- Ensure consistent: label text ("REMAINING" / "CURRENT TIME" / "ELAPSED"), font sizes, spacing

**Files to modify:**
- New file: `lib/widgets/time_display_card.dart` (shared component)
- [`lib/widgets/clock_panel.dart`](lib/widgets/clock_panel.dart:97)
- [`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart:126)
- [`lib/widgets/stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart:116)

---

## Issue 9: Settings Screen — Inconsistent Card Layout

**Problem:** Settings uses separate `_sectionCard` widgets with varying sizes. Sleep Mode card has 1 toggle, System card has 5+ items. Looks uneven and cluttered.

**Fix:**
- Replace separate cards with a single continuous `ListView` of `ListTile`/`SwitchListTile` items
- Use `Divider` between sections instead of separate cards
- Group items visually with section headers (bold text) instead of card containers
- Maintain the same left-padding and icon alignment throughout

**Files to modify:**
- [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart:255) (rewrite `build()` method)

---

## Issue 10: Font Weight Inconsistency

**Problem:** Settings uses `w800` for titles, `w900` for some values. Timer uses `w800` for time, `w600` for labels. Various weights scattered.

**Fix:**
- Define a typography scale:
  - Hero time: `w800` (consistent across all panels)
  - Section titles: `w700`
  - Item titles: `w600`
  - Body text: `w500`
  - Labels/badges: `w500`
  - Values: `w600`
- Audit and fix all font weights across:
  - [`settings_panel.dart`](lib/widgets/settings_panel.dart)
  - [`timer_panel.dart`](lib/widgets/timer_panel.dart)
  - [`clock_panel.dart`](lib/widgets/clock_panel.dart)
  - [`stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart)
  - [`bottom_nav_bar.dart`](lib/widgets/bottom_nav_bar.dart)

**Files to modify:**
- All panel/widget files listed above

---

## Issue 11: Bottom Nav Bar — Remove Underline Indicator

**Problem:** [`BottomNavBar`](lib/widgets/bottom_nav_bar.dart:129) shows a 16×2 accent line below the selected tab icon. User dislikes this.

**Fix:**
- Remove the `IndicatorStyle.accentLine` rendering block (lines 129-138)
- Either remove the underline entirely, or switch to `IndicatorStyle.pill` as default
- If removing: just delete the `if (indicatorStyle == IndicatorStyle.accentLine && selected)` block
- Update the default indicator style in `MainScreen.build()` if needed

**Files to modify:**
- [`lib/widgets/bottom_nav_bar.dart`](lib/widgets/bottom_nav_bar.dart:129)

---

## Issue 12: Task Tracking File

**Problem:** User wants a dedicated markdown file to track completion of all tasks.

**Fix:**
- Create [`plans/v9-checklist.md`](plans/v9-checklist.md) with checkboxes for each issue
- Update after each issue is resolved

---

## Execution Order

1. Create tracking checklist (Issue 12)
2. Fix bottom nav underline (Issue 11) — trivial
3. Fix +5 min timer bug (Issue 3) — critical bug
4. Fix timer font size (Issue 4) — simple
5. Fix notification priority (Issue 1) — requires Android testing
6. Fix settings export location & naming (Issue 5)
7. Fix timer button layout (Issue 7)
8. Fix UI consistency — time display (Issue 8)
9. Fix settings screen layout (Issue 9)
10. Fix font weight consistency (Issue 10)
11. Improve state management (Issue 6) — largest refactor
12. Premium animations & transitions (Issue 2) — polish pass
