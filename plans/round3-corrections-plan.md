# Round 3 Corrections Plan

## Status Legend
- [ ] Not started
- [/] In progress
- [x] Completed

---

## [ ] Item 1: Accessibility Service — Dart-side UI Integration
**What's missing:** The native Android side (BootReceiver, AutoStartAccessibilityService, permissions channel) is implemented. But the Flutter/Dart side has no UI to tell the user about it.

**Files to modify:**
- [`main.dart`](lib/main.dart) — Add `MethodChannel('com.atherpulse.solasflow/permissions')` 
- [`settings_panel.dart`](lib/widgets/settings_panel.dart) — Add "Auto-start on reboot" section with toggle/status

**Implementation:**
```dart
static const MethodChannel _permissionsChannel = MethodChannel(
  'com.atherpulse.solasflow/permissions',
);

Future<bool> checkAccessibilityEnabled() async {
  try {
    return await _permissionsChannel.invokeMethod('isAccessibilityEnabled') ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> openAccessibilitySettings() async {
  await _permissionsChannel.invokeMethod('openAccessibilitySettings');
}
```
Add a row in Settings: "Auto-start after reboot" → shows ON/OFF based on accessibility status → tap opens accessibility settings.

---

## [ ] Item 2: Quick Presets — 5x5 Grid (Smaller Buttons)
**Current:** 4x4 grid (16 presets)  
**Target:** 5 columns x 5 rows = 25 presets with smaller compact buttons.

**Files to modify:**
- [`main.dart`](lib/main.dart:656) — Expand `presetValues` to 25 entries: `[1, 2, 3, 5, 7, 10, 12, 15, 17, 20, 22, 25, 27, 30, 35, 40, 45, 50, 55, 60, 70, 75, 90, 100, 120]`
- [`timer_panel.dart`](lib/widgets/timer_panel.dart:530) — Change `GridView.count(crossAxisCount: 5)` with smaller `childAspectRatio: 1.0` and tighter spacing
- [`timer_panel.dart`](lib/widgets/timer_panel.dart:454) — `_presetChip()`: Use `AspectRatio(1.0)` for more compact square chips, smaller font

---

## [ ] Item 3: Custom Duration Picker — Android Clock App Style
**Current:** Chip row with ChoiceChips for duration selection  
**Target:** A scrollable wheel picker (`ListWheelScrollView` or `CupertinoTimerPicker`) with Material You theming — resembling the Android Clock app's timer duration picker.

**Files to modify:**
- [`timer_panel.dart`](lib/widgets/timer_panel.dart:619) — Replace chip row with a proper Material You timer picker:
  - Three columns: Hours | Minutes | Seconds
  - Or use a `NumberPicker`-style scroll wheel for minutes
  - Use `ListWheelScrollView` for a smooth iOS/Android Clock-like feel
  - Style with Monet colors (cs.primary, cs.surfaceContainerHighest)
  
**Implementation approach:**
```dart
// Option: Custom TimerPicker widget with 3 ListWheelScrollViews
// Hour wheel: 0-23, Minute wheel: 0-59, snap to 5-min intervals
Widget _buildDurationPicker() {
  return Row(
    children: [
      _buildWheel('hour', 0, 23, _selectedHour),
      _buildWheel('min', 0, 59, _selectedMin),
    ],
  );
}
```

---

## [ ] Item 4: Timer Remaining Ring — Visual Improvement
**Current:** The ring is a simple `CustomPaint` with a progress arc and knob.  
**Target:** More polished, premium look — better gradient/thickness, smoother animation, glow/neon effects.

**Files to modify:**
- [`timer_panel.dart`](lib/widgets/timer_panel.dart:811) — `_TimerRingPainter` class:
  - Add a subtle inner/outer shadow to the track
  - Use a gradient on the progress arc instead of solid color
  - Make the knob more prominent (glow/halo effect)
  - Add a slight rounded end cap that scales with progress
  - Consider radial gradient for depth

**Implementation:**
```dart
// Enhanced _TimerRingPainter
@override
void paint(Canvas canvas, Size size) {
  // Draw shadow ring
  // Draw track ring with slightly transparent look
  // Draw progress arc with gradient
  // Draw knob with glow
}
```

---

## [ ] Item 5: Stopwatch Laps — Proper Lap Recording
**Current:** The lap button shows count but doesn't store/display actual lap data.  
**Target:** Proper lap recording with lap times displayed in a list below the elapsed time card.

**Files to modify:**
- [`stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart) — Add `List<({String lapTime, String totalTime})>?` prop
- [`stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart:251) — Replace `_emptyLapCard` with actual lap list when laps exist
- [`main.dart`](lib/main.dart:2801) — `_recordLap()` should store the actual elapsed time at lap moment:
  ```dart
  void _recordLap() {
    final lapTime = stopwatchElapsedValue;
    setState(() {
      _laps.insert(0, (lap: ++_lapCount, time: lapTime));
    });
  }
  ```
- [`main.dart`](lib/main.dart:2804) — Pass `_laps` data to StopwatchPanel

---

## Files Modified Summary

| File | Items |
|------|-------|
| [`main.dart`](lib/main.dart) | 1, 2, 5 |
| [`settings_panel.dart`](lib/widgets/settings_panel.dart) | 1 |
| [`timer_panel.dart`](lib/widgets/timer_panel.dart) | 2, 3, 4 |
| [`stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart) | 5 |

## Execution Order
1. Accessibility Dart-side UI (simplest)
2. Quick presets 5x5 (preset list + grid change)
3. Custom duration picker (medium complexity)
4. Timer ring visual improvement (moderate)
5. Stopwatch lap recording (moderate)
