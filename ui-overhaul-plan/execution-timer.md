# Timer Redesign Rework Plan

## Goal

Redo the Timer screen to match `ui-overhaul-plan/timer_material_you.png` as closely as possible in layout, spacing, color mood, shape language, typography scale, and control hierarchy.

This pass is not a loose "Material You inspired" redesign. The screenshot is the visual source of truth. Existing app features must be preserved, but they should be placed into the mockup's visual system with minimal style deviation.

Also remove the `Made by Atherpulse Technologies` badge/strip from the bottom app bar area entirely.

## Hard Constraints

- Match the timer mockup style with near-zero visual deviation.
- Do not add mockup-only features that do not exist in the app.
- Do not remove existing Timer functionality.
- Do not redesign Clock, Stopwatch, Goals, Settings, fullscreen modes, or service logic.
- Remove the Atherpulse badge from the bottom navigation area.
- Avoid heavy navy borders.
- Avoid boxed/card-heavy legacy layout.
- Avoid dropdowns inside cards.
- Preserve existing callbacks, state, persistence, foreground notification behavior, audio behavior, and TTS behavior.

## Source Of Truth

Primary visual reference:

- `ui-overhaul-plan/timer_material_you.png`

Secondary references only for shared app-shell consistency:

- `ui-overhaul-plan/clock_materialyou.png`
- `ui-overhaul-plan/stopwatch_materialyou.png`
- `ui-overhaul-plan/settings_materialyou.png`

Existing app screenshots are only useful as a feature inventory and as a list of what style to move away from.

## Current Code Locations

- Timer widget: `lib/widgets/timer_panel.dart`
- Timer tab composition: `_buildTimerSetupTab()` in `lib/main.dart`
- Bottom navigation and app bar: `build()` in `lib/main.dart`
- Theme setup: `LiferApp` / `_buildLiferTheme()` in `lib/main.dart`
- Existing legacy quick presets widget: `lib/widgets/presets_panel.dart`
- Shared old palette: `lib/theme/palette.dart`

## Current Timer Features To Keep

- Timer display: `timerDisplayValue`
- Remaining seconds/progress: `seconds`
- Duration: `sliderValue`
- Duration slider: `onSliderChanged`
- Start: `startTimer`
- Pause/stop: `stopTimer`
- Reset: `resetTimer`
- Quick presets: `presetValues`, `choosePreset`
- Fullscreen: `onFullscreenPressed`
- Immersive fullscreen: `onFullscreenImmersivePressed`
- Background noise: `timerNoiseOn`
- Speak remaining time: `timerSpeakOn`
- Show milliseconds: `timerShowMilliseconds`
- Announcement interval: `timerAnnounceEvery`, `timerAnnounceOptions`
- Chain mode: `chainModeOn`
- Chain preset: `chainPresetKey`, `chainPresets`
- Chain step: `chainIndex`
- Voice count: `voices.length`

## Exact Visual Target

### Screen Background

- Very light cool lavender/off-white background.
- No strong borders around the whole content.
- Full screen should feel soft, airy, and high-end.
- Use tonal surfaces with subtle opacity, not shadow-heavy cards.

### App Bar

Match mockup structure:

- Top app title row inside content, not a chunky legacy app bar look.
- Left rounded square menu-style button.
- Large `Timer` title near the top left.
- Right rounded square overflow/action button.
- Existing app actions must still be accessible:
  - Shutdown app
  - Open fullscreen focus
- If both actions do not fit exactly like mockup, use the right overflow button to open a small Material menu containing shutdown/fullscreen.
- Do not show app title `Lifer` in the Timer top bar if it makes the screen deviate from the mockup.

### Mode Pill

Match mockup:

- Centered pill above the circular timer.
- Lavender tonal background.
- Hourglass icon on the left.
- Text should represent the current timer context, such as `Focus Session`, `25 min focus`, or chain step.
- Chevron icon on the right only if it opens a selector/bottom sheet.
- No rectangular dropdown.

### Circular Timer Hero

This is the highest-priority section.

- Large circular ring centered on screen.
- Ring should visually dominate the viewport.
- Pale lavender track.
- Purple progress arc with rounded ends.
- Purple circular knob at the arc end if feasible.
- Center content:
  - Small circular hourglass icon badge.
  - Label like `Focus time` or `Focus in progress`.
  - Very large timer numerals.
  - Supporting text below, using an icon if useful.
- Numerals must be large and visually close to the mockup: dark navy, heavy weight, tabular figures.
- Do not use the previous compact bordered timer panel style.

### Primary And Secondary Actions

Match mockup hierarchy:

- One full-width dominant purple pill button:
  - `Start` when idle
  - `Pause` when running, wired to `stopTimer`
  - Icon on the left
- Below it, two wide tonal pill buttons:
  - `Reset`
  - `Stop`
- Reset button uses pale lavender tonal styling.
- Stop button uses pale red/pink tonal styling.
- Buttons should be tall, rounded, and spacious.
- Do not give Start/Stop/Reset equal visual weight.

### Quick Presets

Match mockup:

- Header row: `Quick presets` on left.
- Optional `Edit` action only if it maps to a real current app feature. Since custom preset editing is not currently implemented, do not add `Edit`.
- Presets rendered as compact vertical rounded tiles/chips:
  - Number large
  - `min` label below
  - Selected preset filled purple
  - Unselected presets pale lavender
- Keep all existing preset values unless screen width requires horizontal scrolling.
- Existing `choosePreset` behavior must remain: selecting a preset starts quickly.

### Advanced Timer Features

The mockup does not show all existing advanced controls. Keep them, but do not let them visually dominate the primary Timer screen.

Use one of these exact-style-compatible approaches:

1. A rounded overflow/menu button in the top right opens a modal bottom sheet named `Timer settings`.
2. The bottom sheet contains all advanced controls using Material You rows, switches, and chips.
3. No advanced controls should appear as heavy bordered expansion cards on the main timer surface.

Controls in the bottom sheet:

- Background noise during timer: switch row
- Speak remaining time: switch row
- Show milliseconds: switch row
- Speak every: filter chips or segmented chips
- Chain timers: switch row
- Chain preset: list row that opens a second bottom sheet or inline selectable list

This preserves all features while keeping the main Timer screen faithful to the mockup.

### Bottom Navigation

Match mockup:

- Use Material 3 `NavigationBar` style.
- Floating/rounded pale container feel if feasible.
- Active item has pill-shaped lavender indicator.
- Timer active icon appears purple.
- Labels are visible and aligned.
- Keep existing destinations and order:
  - Clock
  - Timer
  - Stopwatch
  - Goals
  - Settings
- Remove `Made by Atherpulse Technologies` strip entirely.
- No replacement badge, footer, or brand text in the bottom app bar.

## Implementation Plan

### 1. Undo Or Replace The First Redesign Where It Deviates

- Inspect current `lib/widgets/timer_panel.dart` and `lib/main.dart`.
- Keep useful logic wiring from the first pass:
  - `remainingSeconds`
  - `isRunning`
  - `presetValues`
  - `choosePreset`
- Replace the visual composition with a closer mockup-matching layout.
- Move advanced controls off the main screen into a bottom sheet.

### 2. Timer Screen Layout

Implement `TimerPanel` as:

1. Top row:
   - left rounded square icon button
   - title `Timer`
   - right rounded square overflow/settings button
2. Center mode pill.
3. Circular timer hero.
4. Full-width primary action pill.
5. Two secondary action pills.
6. Quick presets tile row/scroll area.

No outer card around the entire timer panel.

### 3. Progress Ring

- Use `CustomPainter`.
- Draw:
  - pale track circle
  - purple rounded progress arc
  - optional end knob
- Progress calculation:
  - `remainingSeconds / max(sliderValue * 60, 1)`
  - Clamp between `0.0` and `1.0`
- For idle `00:00`, ring should still match mockup visually with a minimal/empty arc rather than disappearing into nothing.

### 4. Advanced Bottom Sheet

- Add private helper in `TimerPanel`, for example `_showTimerSettingsSheet(context)`.
- Trigger from top-right overflow/settings button.
- Use `showModalBottomSheet(showDragHandle: true)`.
- Use rounded top corners and tonal surface from theme.
- Use switches and chips only.
- Use bottom sheet/list selection for chain preset.
- No `DropdownButton`.

### 5. Bottom Navigation Cleanup

In `lib/main.dart`:

- Delete the bottom badge container entirely:
  - Remove `Made by Atherpulse Technologies`
  - Remove its padding and wrapper
- Keep only the `NavigationBar`.
- Tune `NavigationBarThemeData` to match mockup:
  - pale surface
  - pill selected indicator
  - purple selected icon/text
  - muted unselected icons/text
  - no heavy elevation

### 6. Typography

- Use Material/Roboto-like typography already available through Flutter.
- Timer numerals:
  - tabular figures
  - heavy weight
  - responsive large size
  - no negative letter spacing
- Avoid adding network font dependencies during this pass unless explicitly needed later.

### 7. Responsive Checks

Must visually check these sizes:

- 360 x 800
- 390 x 844
- 430 x 932
- 700+ width

Acceptance:

- Timer ring remains dominant.
- Timer numerals never overflow.
- Primary button remains full-width pill.
- Presets scroll/wrap cleanly.
- Bottom navigation does not clip labels.
- No Atherpulse badge appears.

### 8. Verification

Run:

- `/home/starwalker/flutter/bin/dart format lib/main.dart lib/widgets/timer_panel.dart`
- `/home/starwalker/flutter/bin/flutter analyze`
- `/home/starwalker/flutter/bin/flutter test`

Manual behavior checks:

- Start timer.
- Pause timer.
- Stop timer.
- Reset timer.
- Change slider duration.
- Tap quick preset and confirm existing quick-start behavior.
- Toggle all timer settings in bottom sheet.
- Change announcement interval.
- Enable chain mode and change chain preset.
- Tap timer fullscreen.
- Double tap immersive fullscreen.
- Confirm bottom Atherpulse badge is gone.

## Acceptance Criteria

- Timer screen visually resembles `timer_material_you.png` at first glance.
- No heavy bordered panels remain on the Timer screen.
- Main screen is not cluttered by advanced settings.
- Quick presets look like the mockup's rounded preset tiles.
- Main action hierarchy matches the mockup.
- Bottom navigation has mockup-like pill indicator.
- Atherpulse badge is fully removed.
- Existing Timer features still work.
- Analyze and tests pass.

## Files To Edit

- `lib/widgets/timer_panel.dart`
- `lib/main.dart`

Possible but avoid unless necessary:

- `lib/theme/palette.dart`
- `pubspec.yaml`
