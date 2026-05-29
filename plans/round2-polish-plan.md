# Round 2 Polish Plan

## Issue 1: Timer Presets Grid (4x4)

### Current
3 rows of presets: Row1: 5,10,15,20 | Row2: 25,30,45 | Row3: 60,90,120

### Target
Change to a **4x4 grid** — 4 rows x 4 columns = 16 presets.

### Changes needed

1. **Expand `presetValues`** in [`main.dart`](lib/main.dart:656) from 10 to 16 entries:
   ```
   [1, 2, 3, 5, 10, 15, 20, 25, 30, 35, 45, 60, 75, 90, 100, 120]
   ```
2. **Rewrite `_quickPresets()`** in [`timer_panel.dart`](lib/widgets/timer_panel.dart:507) to use a `GridView` with 4 columns:
   ```dart
   GridView.count(
     crossAxisCount: 4,
     shrinkWrap: true,
     physics: const NeverScrollableScrollPhysics(),
     childAspectRatio: 1.2,
     children: presetValues.map((p) => _presetChip(context, p)).toList(),
   )
   ```
3. **Update `_presetChip()`** to work in a grid — it already takes a fixed `SizedBox(40x46)` which needs to be more flexible. Change to fill available space.

### Files to modify:
| File | Lines |
|------|-------|
| [`main.dart`](lib/main.dart:656) | `presetValues` list |
| [`timer_panel.dart`](lib/widgets/timer_panel.dart:454-529) | `_presetChip()` and `_quickPresets()` |

---

## Issue 2: Stopwatch Lap Button

### Current
`_emptyLapCard` shows placeholder text "No laps yet" with no lap recording capability.

### Target
Add a functional lap system:
1. **Lap button** in the stopwatch action row
2. **Lap state tracking** — pass through `List<({int lap, String time, String total})>?` or similar
3. **Lap list display** — replace `_emptyLapCard` with lap list when laps exist

### Changes needed

**`stopwatch_panel.dart`:**
- Add `onLap` callback
- Add `List<({String lap, String time, String total})>?` data
- Replace `_emptyLapCard()` with lap-capable widget
- Add "Lap" button in `_actions()` between Start/Pause and Stop/Reset

**`main.dart`:**
- Add lap tracking state (`List<_LapEntry> _laps = []`)
- Wire up `onLap` callback in `_buildStopwatchTab()`
- Implement `recordLap()` method

### Files to modify:
| File | Changes |
|------|---------|
| [`stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart) | Add `onLap`, `laps` props; update `_actions()` and lap list |
| [`main.dart`](lib/main.dart:2759-2810) | Add lap state in `_buildStopwatchTab()` |

---

## Issue 3: Timer Custom Duration Picker

### Current
A `Slider` widget for 1-120 minute range, inside a card.

### Target
Replace with a **segmented chip row** + **number input** or **spin wheel** UX. Two approaches:

**Option A (Recommended): Quick duration chips + manual input**
- Show a row of 6-8 common durations as chips (1, 5, 10, 15, 25, 30, 45, 60)
- Below chips, show a `TextField` with `SuffixText('min')` for custom values
- The `Slider` is replaced entirely

**Option B: Spin wheel (Cupertino-style)**
- Use a `ListWheelScrollView` or `CupertinoTimerPicker`
- More complex, less Material You aligned

### Files to modify:
| File | Changes |
|------|---------|
| [`timer_panel.dart`](lib/widgets/timer_panel.dart:619-637) | Replace `_durationSection()` slider with chip row + text field |

---

## Issue 4: Bottom Nav Bar Separation

### Current
`NavigationBar` with `elevation: 0` and no shadow, blending into the screen.

### Target
Add Material 3 compliant elevation/shadow to separate nav bar from content.

### Fix
In [`main.dart`](lib/main.dart:250) `_buildSolasFlowTheme()`:
```dart
navigationBarTheme: NavigationBarThemeData(
  height: 78,
  elevation: 3,  // add subtle elevation
  shadowColor: scheme.shadow,
  surfaceTintColor: scheme.surfaceTint,
  ...
)
```

Or wrap the `NavigationBar` in a `Material` widget with elevation.

### Files to modify:
| File | Lines |
|------|-------|
| [`main.dart`](lib/main.dart:250-268) | NavigationBarThemeData elevation and shadow |

---

## Issue 5: Language List — Only English or Malayalam

### Current
3 options in voice mode: Auto, English, Malayalam.

### Target
Remove "Auto" option — user must explicitly pick English or Malayalam only.

### Changes
1. In [`settings_panel.dart`](lib/widgets/settings_panel.dart:449-453), change `voiceModeOptions` from 3 to 2:
   ```dart
   final voiceModeOptions = <(String, String, String?)>[
     ('english', 'English', null),
     ('malayalam', 'Malayalam', null),
   ];
   ```
2. In [`main.dart`](lib/main.dart:648) & [`speech_service.dart`](lib/services/speech_service.dart:648-661), update `normalizeVoiceLanguageMode()` to default to 'english' instead of 'auto'.
3. Update `_initPrefs()` to migrate any user with 'auto' to 'english'.

### Files to modify:
| File | Changes |
|------|---------|
| [`settings_panel.dart`](lib/widgets/settings_panel.dart:449-453) | Remove "Auto" from voice mode options |
| [`speech_service.dart`](lib/services/speech_service.dart:648-661) | Default to 'english' instead of 'auto' |
| [`main.dart`](lib/main.dart:1148) | Handle 'auto' → 'english' migration in `_initPrefs()` |

---

## Issue 6: Help & Status Page Redesign

### Current
Entirely uses old `palette.dart` (hardcoded colors) and `ui_helpers.dart` (old styling). Looks outdated.

### Target
Full Material You redesign with Monet colors, proper card-based layout, smooth expansion tiles.

### Changes needed

**`help_panel.dart`:**
- Remove all references to `palette.dart` and `ui_helpers.dart`
- Use `Theme.of(context).colorScheme` for all colors
- Replace `panelContainer()` with direct `DecoratedBox`
- Replace `headerTitle()` with styled `Text` widget
- Update all `_quickStep()` items to use theme colors
- Update all `_faqItem()`: use `ExpansionTile` with proper Material 3 styling
- Add a status/health section at the top

**Color mapping:**
| Old `palette.*` | Replace with |
|----------------|--------------|
| `palette.primary` | `cs.primary` |
| `palette.accent` | `cs.surfaceContainerLow` |
| `palette.bg` | `cs.surface` |

### Files to modify:
| File | Changes |
|------|---------|
| [`help_panel.dart`](lib/widgets/help_panel.dart) | Full rewrite — remove palette, use Theme.of(context).colorScheme |

---

## Execution Order

1. **Help & Status redesign** — independent file change
2. **Nav bar elevation** — single-line change
3. **Language list** — remove "Auto" option
4. **Timer presets 4x4 grid** — update preset list + grid layout
5. **Timer duration picker** — replace slider with chips + input
6. **Stopwatch lap button** — add lap functionality
