# SolasFlow UI Redesign — Fresh from Scratch

## Design Philosophy

This is a **focus tool**, not a settings app. Every screen should have:
- **One hero element** — the thing the user came to see (time)
- **One primary action** — the thing the user came to do (start/stop)
- **Everything else is secondary** — tucked away, not competing

## Visual System

### Colors
- Background: `cs.surface` — clean, light, consistent across all tabs (no more per-panel tints)
- Heroes: Large typography on `cs.surfaceContainerLow` rounded containers (no gradients)
- Primary action: `FilledButton` with `cs.primary` (purple)
- Secondary actions: `FilledButton.tonal` with `cs.primaryContainer`
- Destructive (Stop): `FilledButton.tonal` with `cs.errorContainer`
- Text: `cs.onSurface` for primary, `cs.onSurfaceVariant` for secondary

### Typography Scale (for time displays)
- Timer hero: 56px `FontWeight.w900`, tabular figures
- Clock hero: 52px `FontWeight.w900`, tabular figures
- Stopwatch hero: 48px `FontWeight.w900`, tabular figures
- All on tonal background, no gradient

### Spacing
- 24px padding around content
- 20px between sections
- 16px between related items
- Compact mode on landscape

### Shapes
- Hero containers: `BorderRadius.circular(24)` — soft and modern
- Primary button: full-width pill (`StadiumBorder`)
- Secondary buttons: `BorderRadius.circular(14)` 
- Chips: `BorderRadius.circular(12)`

---

## Screen-by-Screen Design

### 1. Timer Tab

```
┌────────────────────────────────────┐
│ Timer                        🔲 🔌 │  ← Title row, fullscreen + exit icons
│                                    │
│        ┌──────────────┐           │
│        │              │           │
│        │   Progress   │           │  ← Large circular ring (CustomPainter)
│        │    Ring      │           │     pale lavender track, purple arc
│        │              │           │     time numerals in center
│        │   25:00      │           │
│        │              │           │
│        └──────────────┘           │
│      Focus Session                │  ← Mode label
│      Ends at 10:30 AM             │  ← End time hint
│                                    │
│  ┌──────────────────────────────┐ │
│  │ ▶ Start                      │ │  ← Primary FilledButton pill
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────┐ ┌──────────────┐│
│  │ ↻ Reset      │ │ ◼ Stop       ││  ← Tonal secondary + error
│  └──────────────┘ └──────────────┘│
│                                    │
│  Quick Presets                     │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐  │
│  │ 5│ │10│ │15│ │25│ │30│ │45│ …│  ← Horizontal scroll of chips
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘  │
│                                    │
│  (Advanced options in bottom sheet)│
└────────────────────────────────────┘
```

**Advanced options** — triggered by top-right ⚙ icon → `showModalBottomSheet`:
- Background noise: switch
- Speak remaining time: switch  
- Show milliseconds: switch
- Announcement interval: chip selector
- Chain timers: switch + preset selector

---

### 2. Clock Tab

```
┌────────────────────────────────────┐
│ Clock                         🔲 🔌│
│                                    │
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │        03:45:30              │ │  ← Large time on tonal surface
│  │          PM                  │ │     no gradient, just clean type
│  │                              │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ 🔊 Speech              [ON] │ │  ← Prominent speech toggle
│  └──────────────────────────────┘ │  (since this IS the speaking clock)
│                                    │
│  Clock options                     │
│  ┌──────────────────────────────┐ │
│  │ Interval          [30 min] ▸ │ │
│  │ ──────────────────────────── │ │
│  │ Show seconds            [✓] │ │
│  │ ──────────────────────────── │ │
│  │ Show milliseconds       [✓] │ │
│  │ ──────────────────────────── │ │
│  │ Announce time           [✓] │ │
│  │ ──────────────────────────── │ │
│  │ Repeat count          [1] ▸ │ │
│  │ ──────────────────────────── │ │
│  │ Background sound        [✓] │ │
│  │ ──────────────────────────── │ │
│  │ Motivational quotes     [✓] │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

Key changes from current:
- Remove gradient card — use `surfaceContainerLow` tonal container
- Move speech toggle HERE (from settings) since clock's purpose IS speaking
- Keep options compact with the card pattern from A2

---

### 3. Stopwatch Tab

```
┌────────────────────────────────────┐
│ Stopwatch                    🔲 🔌│
│                                    │
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │        00:12:45              │ │  ← Large elapsed on tonal surface
│  │      hr  min  sec  ms        │ │
│  │                              │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ ▶ Start                      │ │  ← Primary FilledButton pill
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────┐ ┌──────┐ ┌──────────┐  │
│  │ ⚑ Lap│ │ ◼ Stop│ │ ↻ Reset │  │  ← Tonal buttons
│  └──────┘ └──────┘ └──────────┘  │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ Lap 1          00:02:15      │ │
│  │ Lap 2          00:01:30      │ │  ← Lap times list
│  │ Lap 3          00:03:00      │ │
│  └──────────────────────────────┘ │
│                                    │
│  Options: Speak [✓]  ms [✓]       │  ← Compact row, not a full card
│           Every [60s ▸]           │
└────────────────────────────────────┘
```

Key changes from current:
- Remove gradient card — use tonal surface
- Options as a compact chip row, not a card
- Lap list stays (functional, no redesign needed)

---

### 4. Settings Tab

Keep the 5-section structure from A2, but replace `_card()` with tonal containers. The key change is visual density — more spacing, softer surfaces.

```
┌────────────────────────────────────┐
│ Settings                           │
│                                    │
│ Audio & Speech                     │
│ ┌──────────────────────────────┐  │
│ │ 🔊 Speech              [ON] │  │  ← Global speech master toggle
│ │ ──────────────────────────── │  │     (moved from A5 placement)
│ │ 🎵 Background sound  [Rain]▸│  │
│ │ ──────────────────────────── │  │
│ │ 🔊 Noise volume     [Medium]▸│  │
│ │ ──────────────────────────── │  │
│ │ 🎤 Speech volume      [High]▸│  │
│ │ ──────────────────────────── │  │
│ │ 🔊 Max volume            [✓]│  │
│ └──────────────────────────────┘  │
│                                    │
│ Voice                              │
│ ┌──────────────────────────────┐  │
│ │ ...                           │  │
│ └──────────────────────────────┘  │
│                                    │
│ ... (repeating pattern)            │
└────────────────────────────────────┘
```

Key changes:
- Replace `_card()` border with `surfaceContainerLow` tonal background
- More vertical spacing between sections
- Same content as A2, just softer visual

---

### 5. Bottom Navigation

Keep the `NavigationBar` but make it match the app's purple identity:
- Selected: purple pill indicator, purple icon/text
- Unselected: muted `onSurfaceVariant`
- Rounded top, no shadow
- 4 destinations: Clock | Timer | Stopwatch | Settings
- Timer default (from A4)

---

## Implementation Order

```
Step 1: Timer panel — circular ring hero + clean action layout + bottom sheet for advanced
Step 2: Clock panel — remove gradient, tonal hero, move speech toggle
Step 3: Stopwatch panel — remove gradient, tonal hero, compact options
Step 4: Settings panel — tonal containers instead of bordered cards, more spacing
Step 5: Bottom nav polish + consistent panel backgrounds
Step 6: Full audit — verify all features still work, run analyzer
```

## Files to Create/Modify

| Step | Files | Description |
|------|-------|-------------|
| 1 | `lib/widgets/timer_panel.dart` | Circular ring hero, clean action layout, bottom sheet for advanced |
| 1 | `lib/main.dart` | Update `_buildTimerSetupTab` wiring |
| 2 | `lib/widgets/clock_panel.dart` | Tonal hero, speech toggle, compact options |
| 2 | `lib/main.dart` | Update `_buildSpeakClockTab` wiring |
| 3 | `lib/widgets/stopwatch_panel.dart` | Tonal hero, compact options row |
| 3 | `lib/main.dart` | Update `_buildStopwatchTab` wiring |
| 4 | `lib/widgets/settings_panel.dart` | Tonal containers, more spacing |
| 5 | `lib/main.dart` | Consistent backgrounds, nav bar polish |
