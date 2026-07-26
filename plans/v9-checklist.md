# SolasFlow v9 — Task Completion Checklist

> **Tracking all tasks from the user's multi-part request.**
> Each item has a checkbox. Mark `[x]` when done.

---

## Critical Bug Fixes

- [x] **Issue 3:** Fix +5 min timer bug — shows 15:00 instead of 14:58 when adding time to running timer
  - Added [`addTimeToRunningTimer()`](lib/main.dart:3058) method that adds seconds directly to `seconds` without resetting
  - Updated [`TimerPanel`](lib/widgets/timer_panel.dart:26) to use new callback for running-state +/- buttons
- [x] **Issue 1:** Fix notification priority conflict with ThoughtFlow app in notification drawer
  - Changed channel from `MIN` to `LOW` importance in [`FlutterForegroundTask.init()`](lib/main.dart:669)
  - Renamed channel to `com.atherpulse.solasflow.timer_fg` for uniqueness
- [~] **Issue 6:** Fix state management — toggles don't update reactively
  - **Status:** Flagged for dedicated refactoring session. Requires Provider/Riverpod integration.
  - The root cause is that `SettingsPanel` is opened via `Navigator.push` (separate route), so parent `setState` doesn't trigger `didUpdateWidget` on the panel.

## Timer Screen Improvements

- [x] **Issue 4:** Increase timer remaining time font size in non-fullscreen mode
  - Changed from 40px to 56px with `FittedBox` in [`timer_panel.dart:172`](lib/widgets/timer_panel.dart:172)
  - Increased ring size from 180→200 for better visual balance
- [x] **Issue 7:** Combine timer action buttons into one line (remove stacked layout)
  - Merged Reset + [-1 min] + [+5 min] into a single row when running
  - Removed the separate adjustment row below

## UI Consistency & Design

- [x] **Issue 8:** Standardize time display format across Clock, Timer, and Stopwatch panels
  - All three panels now use consistent container styling, font sizes, and label patterns
- [x] **Issue 9:** Redesign settings screen — single continuous list instead of inconsistent cards
  - Replaced [`_sectionCard()`](lib/widgets/settings_panel.dart:550) with flat [`_sectionHeader()`](lib/widgets/settings_panel.dart:550)
  - Settings now flows as one continuous `ListView` with section headers
- [x] **Issue 10:** Standardize font weights across all screens
  - Section titles: `w700`, Item titles: `w600`, Body: `w500`, Values: `w600`
  - Updated across all panels and settings helpers
- [x] **Issue 11:** Remove underline indicator from bottom navigation bar
  - Removed `IndicatorStyle.accentLine` block from [`bottom_nav_bar.dart:129`](lib/widgets/bottom_nav_bar.dart:129)
  - Added `AnimatedScale` for subtle selection animation instead

## Animations & Polish

- [x] **Issue 2:** Add premium animations and transitions
  - Tab transition: 220ms→350ms with `Curves.easeOutQuart` + scale animation
  - Settings page: custom `PageRouteBuilder` with slide-from-bottom + fade
  - Bottom nav: `AnimatedScale` (0.85→1.0) on icon selection
  - Tab content: `AnimatedSwitcher` with fade + slide + scale

## Backup & Export

- [x] **Issue 5:** Fix settings export to save in user-chosen folder with proper naming
  - Changed [`exportToTempFile()`](lib/services/settings_service.dart:338) → [`exportToUserFolder()`](lib/services/settings_service.dart:338)
  - Uses `FilePicker.platform.getDirectoryPath()` for user folder selection
  - Filename: `SolasFlow_Settings_YYYY-MM-DD_HHmm.json`
  - Removed unused `path_provider` import

---

## Completion Status

| Issue | Status | Notes |
|-------|--------|-------|
| Issue 1 (Notification) | ✅ Done | Channel LOW importance, unique ID |
| Issue 2 (Animations) | ✅ Done | 350ms transitions, scale, slide, fade |
| Issue 3 (+5 min bug) | ✅ Done | Uses `addTimeToRunningTimer()` |
| Issue 4 (Font size) | ✅ Done | 56px with FittedBox |
| Issue 5 (Export path) | ✅ Done | User-chosen folder, proper naming |
| Issue 6 (State mgmt) | ⚠️ Partial | Needs Provider/Riverpod refactor |
| Issue 7 (Button layout) | ✅ Done | Single row when running |
| Issue 8 (UI consistency) | ✅ Done | Standardized across panels |
| Issue 9 (Settings layout) | ✅ Done | Flat continuous list |
| Issue 10 (Font weights) | ✅ Done | w700/w600/w500 scale |
| Issue 11 (Nav underline) | ✅ Done | Removed + AnimatedScale |
| Issue 12 (Tracking file) | ✅ Done | This file |
