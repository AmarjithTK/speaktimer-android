# SolasFlow UI Redesign — Premium Minimalist Clock App

## Design Philosophy

**This is a beautiful clock app that happens to have an excellent design system — not a developer tool that happens to have a clock.**

The design draws shadcn-inspired principles for surfaces, borders, typography, and spacing, but does not imitate the visual identity of Linear, Raycast, or any SaaS product. The app retains its own identity as a calm, premium time utility.

The sweet spot: better typography, better spacing, better surfaces, better hierarchy, better visual polish — while keeping the product unmistakably a Clock / Timer / Stopwatch app.

### Core Principles

1. **Time is the hero** — The display of time should dominate, not decorative elements
2. **Calm over clever** — Minimal, but not sterile; premium, but not cold
3. **Borders over shadows** — Subtle 1px borders instead of elevation
4. **Neutral surfaces** — No primary-tinted containers; clean white/dark
5. **Strong typography** — Inter font, clear hierarchy, tabular figures
6. **Accent used sparingly** — Only for active states, primary actions, progress
7. **Accessible personality** — Sound, Noise, Quotes, Speech stay visible and tappable

---

## Current State Summary

The app is a Flutter Material 3 productivity timer (Clock / Timer / Stopwatch) with:
- **Font**: Poppins via `GoogleFonts` — round, playful, not premium
- **Theme**: `ColorScheme.fromSeed(seedColor: 0xFF6256D9)` with `_darkenColors()` post-processing
- **Surfaces**: Primary-tinted containers (`tintedSurface` = `primaryContainer@0.15`) — creates a blue-ish wash
- **Components**: `StadiumBorder` pill buttons, 18–28px rounded cards, `ExpansionTile` for options
- **Timer ring**: Custom painter with shadow glow, gradient sweep, knob highlight — visually busy
- **Layout**: All panels are `ListView` with hero area + controls + options — functional but flat
- **Dark mode**: Inverted via `brightness` switch — not first-class, same component shapes

---

## Phase 1 — Design System Foundation

### 1A. Typography

**Replace Poppins with Inter.** Inter is neutral, crisp, excellent tabular figures — without feeling like a developer tool font.

```
Font family: Inter (via GoogleFonts.inter)
Fallback: system default
```

**Type scale** (using `TextTheme`):

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `displayLarge` | 64–72px | w800 | Timer/Clock hero digits |
| `displayMedium` | 48–56px | w800 | Clock hero digits (smaller screens) |
| `headlineSmall` | 22–24px | w700 | Screen titles in AppBar |
| `titleMedium` | 16px | w600 | Section headers, card titles |
| `bodyLarge` | 15px | w400–w500 | Primary body text |
| `bodyMedium` | 14px | w400–w500 | Secondary text, option labels |
| `bodySmall` | 12–13px | w500–w600 | Status badges, metadata |
| `labelLarge` | 14px | w700 | Button text |
| `labelMedium` | 12–13px | w600 | Nav labels, chip text |
| `labelSmall` | 11px | w600 | Compact badges |

All text uses `FontFeature.tabularFigures()` for time displays.

### 1B. Color System

**Do NOT default to generic Tailwind blue (#2563EB).** Use a refined indigo-violet accent that derives from the existing app identity (`0xFF6256D9`) but is cleaner and less saturated.

**Light mode:**
```
Background:       #FAFAFA (near-white, not pure white)
Surface:          #FFFFFF
Surface border:   #E8E8E8 (subtle 1px)
Text primary:     #111111 (near-black)
Text secondary:   #6B6B6B
Text muted:       #A0A0A0
Accent:           #5B5BD6 (refined indigo-violet — distinctive, not generic blue)
Accent light:     #F0F0FF (subtle indigo tint for selected states)
Accent border:    #C7C7F0
Primary action:   #4F46E5 (indigo-600, slightly deeper for buttons)
Destructive:      #DC2626 (red-600, ONLY for genuinely destructive actions)
```

**Dark mode:**
```
Background:       #0A0A0A (near-black)
Surface:          #141414 (neutral-900)
Surface border:   #262626 (neutral-800)
Text primary:     #F0F0F0
Text secondary:   #9A9A9A
Text muted:       #555555
Accent:           #7C7CEF (lighter indigo for dark backgrounds)
Accent light:     #1A1A2E (dark indigo tint)
Accent border:    #2A2A4A
Primary action:   #6366F1 (indigo-500, lighter for dark)
Destructive:      #EF4444 (red-400)
```

**Usage rules — accent is used ONLY for:**
- Active/selected navigation indicator
- Primary action button fill (Start, Pause, Resume)
- Progress ring arc (timer)
- Active toggle states
- Selected preset chip
- PM indicator in fullscreen clock (optional, tasteful)

### 1C. Spacing & Radii

```
Border radius:
  Small (chips, badges):     8px
  Medium (cards, buttons):   12px
  Large (bottom sheets):     16px

Spacing scale:
  xs:  4px
  sm:  8px
  md:  12px
  lg:  16px
  xl:  24px
  2xl: 32px
```

### 1D. Component Primitives

**Borders over shadows.** Surfaces use `1px solid` border instead of elevation. But not everything is flat — important elements get subtle visual emphasis.

| Component | Style |
|-----------|-------|
| Card | Surface background, 1px border, 12px radius, no shadow |
| Timer hero area | Subtle surface with 1px border — gives the timer visual presence without being a heavy card |
| Button (primary) | Primary action fill, white text, 12px radius, 48px height |
| Button (secondary) | Transparent, 1px border, 12px radius, 44px height |
| Chip (preset) | Transparent, 1px border, 8px radius, 36px height |
| Chip (selected) | Accent-light fill, accent border, accent text |
| Settings row | Transparent, bottom border separator, no card |
| Toggle | Custom minimal switch (not default Material) |
| Bottom nav | Surface background, top 1px border, minimal elevation |
| Bottom sheet | Surface background, 16px top radius, 1px border |

**Not everything is flat.** The rule is:
- Most things are flat (settings rows, toggles, chips)
- Important things get subtle visual emphasis (timer display area, primary buttons)
- This avoids both the "everything is a card" and "everything is flat" extremes

---

## Phase 2 — Shared Components

### New files to create:

| File | Purpose |
|------|---------|
| `lib/theme/app_theme.dart` | Theme builder replacing `_buildSolasFlowTheme()` |
| `lib/theme/app_colors.dart` | Hand-crafted color constants for light/dark |
| `lib/widgets/display_text.dart` | Large time/clock display component |
| `lib/widgets/primary_button.dart` | Styled primary action button |
| `lib/widgets/secondary_button.dart` | Styled secondary/outline button |
| `lib/widgets/preset_grid.dart` | Wrap-based preset duration grid with hierarchy |
| `lib/widgets/settings_row.dart` | Clean settings row with label + value + chevron |
| `lib/widgets/toggle_switch.dart` | Minimal custom toggle switch |
| `lib/widgets/section_header.dart` | Uppercase small-caps section label |
| `lib/widgets/bottom_nav_bar.dart` | Custom bottom navigation bar |

### Component specs:

**`DisplayText`** — Used for all large time displays:
```dart
// The TIME itself is the hero — not a ring, not a card
// Clock: 06:45:44 with PM below in accent
// Timer: 09:43 large, "Remaining" above in muted text
// Stopwatch: 00:12:34 large, "ELAPSED" above in muted text
// Font: Inter w800, tabular figures
// Color: text primary
// FittedBox for responsive scaling
```

**`PresetGrid`** — Replaces both `PresetChipBar` and the inline grid:
```dart
// Hierarchical layout — common presets prominent, less-used secondary
//
// Quick presets (primary row):
//   5m  10m  15m  25m  45m
//
// More durations (secondary, slightly muted or smaller):
//   1m  2m  3m  7m  12m  20m  30m  35m  1h  Custom
//
// Each chip: outlined, 8px radius
// Selected: accent fill + accent border
// Armed (two-tap): primary border + tertiary fill
// Labels: "1m", "2m", ... "1h", "Custom"
```

**`SettingsRow`** — Replaces `optionRow`, `toggleRow`, `ListTile` for settings:
```dart
// Full-width row
// Left: icon (optional) + label
// Right: value text + chevron (or toggle)
// Separator: 1px bottom border (inset from edges)
// No background, no card wrapper
```

**`ToggleSwitch`** — Minimal custom toggle:
```dart
// 44x24 track, 18px thumb
// Off: neutral-200 track, white thumb
// On: accent track, white thumb
// Smooth animation
```

---

## Phase 3 — Theme Rewrite

### Changes to `lib/main.dart`:

1. **Replace `_buildSolasFlowTheme()`** with new `AppTheme.build()` from `lib/theme/app_theme.dart`
2. **Remove `_darkenColors()`** — no longer needed with hand-crafted colors
3. **Remove `DynamicColorBuilder`** — use fixed color scheme for consistency and predictability
4. **Keep `appThemeModeNotifier`** for light/dark toggle

### Changes to `lib/theme/palette.dart`:

1. **Delete all deprecated classes** (`Palette`, `_lightPalette`, `_darkPalette`, `setPaletteDarkMode`)
2. **Keep `ThemeColors` and `ThemeTypography` extensions** — rename to shorter helpers
3. **Remove `TintedSurfaces` extension** — no more primary-tinted surfaces
4. **Add new extension** for the custom color tokens:

```dart
extension AppColors on BuildContext {
  Color get bgPrimary => /* light: #FAFAFA, dark: #0A0A0A */;
  Color get bgSurface => /* light: #FFFFFF, dark: #141414 */;
  Color get borderDefault => /* light: #E8E8E8, dark: #262626 */;
  Color get borderSubtle => /* light: #F0F0F0, dark: #1F1F1F */;
  Color get textPrimary => /* light: #111111, dark: #F0F0F0 */;
  Color get textSecondary => /* light: #6B6B6B, dark: #9A9A9A */;
  Color get textMuted => /* light: #A0A0A0, dark: #555555 */;
  Color get accent => /* light: #5B5BD6, dark: #7C7CEF */;
  Color get accentLight => /* light: #F0F0FF, dark: #1A1A2E */;
  Color get accentBorder => /* light: #C7C7F0, dark: #2A2A4A */;
  Color get primaryAction => /* light: #4F46E5, dark: #6366F1 */;
  Color get destructive => /* light: #DC2626, dark: #EF4444 */;
}
```

### Changes to `lib/widgets/ui_helpers.dart`:

1. **Remove `themedCard()`** — replaced by individual component styling
2. **Rewrite `sectionLabel()`** — uppercase, letter-spaced, smaller
3. **Remove `primaryAction()`** — replaced by `PrimaryButton` widget
4. **Remove `toggleRow()`** — replaced by `SettingsRow` + `ToggleSwitch`
5. **Remove `optionRow()`** — replaced by `SettingsRow`
6. **Keep `sectionTitle()`** — restyle with new typography

---

## Phase 4 — Clock Screen Redesign

### [`ClockPanel`](lib/widgets/clock_panel.dart) — Full rewrite

**Layout (top to bottom):**

```
┌─────────────────────────────────┐
│  [hamburger]    Clock    [⛶] [⏻]│  ← AppBar (simplified)
├─────────────────────────────────┤
│                                 │
│        06:45:44 PM              │  ← Large time directly on background
│     Wednesday, July 24          │     PM in accent color (subtle)
│                                 │     Date in muted text
│  ┌──────────────────────────┐   │
│  │ 🔊  Announce every 10 min > │  ← Compact row with chevron
│  └──────────────────────────┘   │     (subtle surface, 1px border)
│                                 │
│  ┌────┐ ┌────┐ ┌────┐          │
│  │ 🔊 │ │ 🎵 │ │ 💬 │          │  ← 3 columns: Sound / Noise / Quotes
│  │Sound│ │Noise│ │Quotes│        │     with On/Off status
│  │ On  │ │ Off │ │ Off  │        │     These are ALWAYS accessible —
│  └────┘ └────┘ └────┘          │     not buried in settings
│                                 │
│  ── Clock options ────────── >  │  ← Settings row with chevron
│                                 │
└─────────────────────────────────┘
```

**Key changes:**
- Remove the tinted container around the clock display — show time directly on the background
- AM/PM as text next to time (not a badge), smaller and lighter; PM in accent color
- Date below in muted text
- "Announce every 10 min" as a single compact row (icon + text + chevron), on a subtle surface with 1px border
- Sound/Noise/Quotes as 3 equal columns with icon, label, and On/Off status — outlined, not filled
- **These three features stay prominently visible** — they are the app's personality
- Clock options as a single settings row with chevron

---

## Phase 5 — Timer Screen Redesign

### [`TimerPanel`](lib/widgets/timer_panel.dart) — Full rewrite

**Design principle: The time itself is the hero. The ring supports the time, not the other way around.**

**Layout (top to bottom):**

```
┌─────────────────────────────────┐
│  [≡]       Timer       [⛶] [⏻]│  ← AppBar
├─────────────────────────────────┤
│                                 │
│    ╭───────────────────────╮    │  ← Timer display area: subtle
│    │                       │    │     surface with 1px border
│    │        09:43          │    │     (visual presence without being
│    │      Remaining        │    │      a heavy card)
│    │  ─────────────────    │    │  ← Thin progress bar below time
│    ╰───────────────────────╯    │     (cleaner than ring for this)
│                                 │
│  ┌─────────────────────────────┐│
│  │     ▶  Start                ││  ← Primary button (full width)
│  └─────────────────────────────┘│
│                                 │
│  ┌──────────┐  ┌──────────┐    │  ← Secondary buttons (when running)
│  │ ↻ Reset  │  │ + 5 min  │    │
│  └──────────┘  └──────────┘    │
│                                 │
│  Quick presets                  │  ← Section label
│  ┌────┐ ┌─────┐ ┌────┐ ┌────┐ │  ← Primary presets (prominent)
│  │ 5m │ │ 10m │ │15m │ │25m │ │
│  └────┘ └─────┘ └────┘ └────┘ │
│                                 │
│  More durations                 │  ← Secondary label (muted)
│  ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐   │  ← Secondary presets (slightly muted)
│  │1m││2m││3m││7m││12││20│   │
│  └──┘└──┘└──┘└──┘└──┘└──┘   │
│  ┌───┐┌───┐┌──┐┌─────┐       │
│  │30m││35m││1h││Custom│       │
│  └───┘└───┘└──┘└─────┘       │
│                                 │
│  ── Speech          On     >   │  ← Settings rows
│  ── Noise          Off     >   │
│  ── End of timer    Sound >   │
│  ── Timer options       >      │
│                                 │
└─────────────────────────────────┘
```

**Timer display area:** A subtle surface with 1px border — giving the timer visual presence and separation without being a heavy Material card. The time is large and dominant within this area.

**Progress visualization:** A thin progress bar below the time (or optionally the cleaned-up ring as an alternative). The bar is simpler, cleaner, and doesn't compete with the time for attention.

**Timer states:**

| State | Display | Button | Presets | +5/-1 |
|-------|---------|--------|---------|-------|
| Idle | 00:00 or preset time, muted | "Start" (primary action fill) | Visible, selectable | Hidden |
| Running | Countdown, animated | "Pause" (primary action fill) | Visible, dimmed | Visible |
| Paused | Frozen time | "Resume" (primary action fill) | Visible, selectable | Visible |
| Completed | 00:00 + subtle pulse | "Start" (primary action fill) | Visible, selectable | Hidden |

**Timer ring (if kept as alternative):**
- Remove outer shadow glow
- Remove knob highlight/specular
- Track ring (border-subtle), progress arc (accent), small dot at arc end
- Ring stroke: 3px (thinner, more refined)
- The ring should frame the time, not dominate it

**+5 min / -1 min controls:**
- Two outlined buttons side by side below the main action
- Only visible when timer is running or paused
- Secondary styling (outlined, not filled)

**Preset hierarchy:**
- Primary row: 5m, 10m, 15m, 25m, 45m (most common, full visual weight)
- Secondary section: 1m, 2m, 3m, 7m, 12m, 20m, 30m, 35m, 1h, Custom (slightly muted or smaller)
- This reduces visual overload while preserving all options

---

## Phase 6 — Stopwatch Screen Redesign

### [`StopwatchPanel`](lib/widgets/stopwatch_panel.dart) — Full rewrite

**Layout:**

```
┌─────────────────────────────────┐
│  [≡]     Stopwatch     [⛶] [⏻]│
├─────────────────────────────────┤
│                                 │
│          ELAPSED                │  ← Small uppercase label
│        00:12:34                 │  ← Large time display (hero)
│         3 laps                  │  ← Lap count (if >0)
│                                 │
│  ┌──────────┐  ┌──────┐  ┌───┐ │
│  │▶ Start   │  │ Lap  │  │ ↻ │ │  ← Start/Lap/Reset row
│  └──────────┘  └──────┘  └───┘ │
│                                 │
│  Lap 3   00:12:34   +00:03:12  │  ← Lap list (clean rows)
│  Lap 2   00:09:22   +00:04:10  │
│  Lap 1   00:05:12   +00:05:12  │
│                                 │
│  ── Speech          Off     >  │
│  ── Show ms         Off     >  │
│  ── Speak delay    30s      >  │
│                                 │
└─────────────────────────────────┘
```

**Key changes:**
- Cleaner hero area without tinted container
- Lap list with clean rows: lap number, cumulative time, delta time
- Consistent settings row styling
- Time is the hero (same principle as timer)

---

## Phase 7 — Bottom Navigation Redesign

### Approach: Prototype both, decide based on visual balance

**Option A — Minimal accent line:**
```dart
// Surface background with top 1px border
// Active: accent color icon + label + small accent line below
// Inactive: muted text, muted icon
// Height: 64px (compact)
```

**Option B — Subtle active indicator:**
```dart
// Same surface background and border
// Active: accent color icon + label + subtle rounded pill indicator behind
// Inactive: muted text, muted icon
// Height: 64px
// The pill uses accent-light background, not accent fill
```

**Implementation:** Build the custom `BottomNavBar` with a parameter to switch between modes. Test both visually before deciding. Do NOT force the shadcn accent-line style — use whichever provides better affordance.

**Icons:**
- Clock: `Icons.watch_later_outlined` / `Icons.watch_later`
- Timer: `Icons.hourglass_empty` / `Icons.hourglass_top`
- Stopwatch: `Icons.timer_outlined` / `Icons.timer`

---

## Phase 8 — AppBar Redesign

```dart
// Background: surface (white/dark)
// No elevation, no shadow
// Height: 52px
// Title: Inter w700, 18px, centered
// Leading: hamburger/settings icon (opens settings bottom sheet)
// Actions: fullscreen icon (neutral color), exit icon (neutral color)
// Border: subtle bottom 1px
```

**Important:** The power/exit icon should be **neutral colored** (not destructive red) unless it performs a genuinely destructive action like data deletion. For "exit app" or "close", use a neutral icon color. Destructive red is reserved for actual destructive operations.

---

## Phase 9 — Settings Panel Redesign

### [`SettingsPanel`](lib/widgets/settings_panel.dart) — Restyle as bottom sheet

The settings panel currently opens as a full-screen route. Restyle as a **modal bottom sheet** with:
- Drag handle at top
- Surface background
- 16px top radius
- Scrollable content
- Grouped sections with section headers
- Each setting as a `SettingsRow` (label + value + chevron or toggle)
- Bottom padding for safe area

**Not a dense settings clone.** Group with generous spacing:

```
Settings
─────────────────

Audio
  Sound                        Rain >
  Noise volume            ━━━━━●━━━

Speech
  Speech                       On >
  Speak volume            ━━━━━━●━

Display
  Dark theme                   Off >

Fullscreen
  Dark background              On >
  Dim brightness               Off >

Sleep
  Mute after midnight          On >
  Night mode           Auto-mute >
  Quiet hours       11 PM – 6 AM >

About
  Help                          >
  Accessibility                 >
```

---

## Phase 10 — Fullscreen Clock Redesign

### [`FullscreenFocusView`](lib/widgets/fullscreen_focus_view.dart) — Refine

**This is excellent in the current plan — keep as-is.**

**Clock mode layout:**
```
┌─────────────────────────────────┐
│  [✕]     [🔒 Awake]  [☾][🔊][⛶] │  ← Minimal top bar, auto-hide
│                                 │
│                                 │
│        06:45:56                 │  ← Huge time, Inter w800
│           PM                    │  ← Accent color, medium size
│     Wednesday, July 24          │  ← Muted text
│                                 │
│                                 │
│                                 │
│                                 │
│  "Double tap anywhere to exit"  │  ← Hint, fades after 2s
└─────────────────────────────────┘
```

**Key changes:**
- Near-black background (#0A0A0A)
- No cards, no containers, no borders
- Time is the only visual element
- PM in accent color (tasteful)
- Date in muted text
- Top controls: minimal icons, auto-hide after 3s
- Entry hint fades away (refine timing)
- Close button (✕) top-left instead of hamburger

**Timer mode in fullscreen:**
- Same dark background
- Timer display with time as hero
- Minimal controls below: Start/Pause, Reset (auto-hide)

---

## Phase 11 — Fullscreen Stopwatch Redesign

### [`FullscreenStopwatchView`](lib/widgets/fullscreen_stopwatch_view.dart) — Refine

Same pattern as fullscreen clock:
- Near-black background
- Huge elapsed time
- "ELAPSED" label above
- Minimal controls that auto-hide
- Consistent with fullscreen clock

---

## Phase 12 — Responsive Design

### Mobile (< 600px)
- Single column, full width
- Hero display: 64–72px font
- Preset grid: primary row 4-5 columns, secondary wrap
- Padding: 16px horizontal

### Tablet (600–900px)
- Centered content with max-width ~480px
- Same proportions, just centered

### Desktop (> 900px)
- Centered card layout, max-width 420px
- Simulates phone form factor

**Implementation:** Use `LayoutBuilder` or `ConstrainedBox` with max-width constraints. The core UI stays phone-width; it just centers on larger screens.

---

## Phase 13 — Cleanup

1. Delete `lib/widgets/presets_panel.dart` (replaced by `preset_grid.dart`)
2. Remove `TintedSurfaces` extension from `lib/theme/palette.dart`
3. Remove all `context.tintedSurface*` usages
4. Remove `DynamicColorBuilder` wrapper from `lib/main.dart`
5. Run `flutter analyze` — fix all warnings
6. Run `flutter test` — ensure no regressions

---

## Files Modified Summary

| File | Action | Phase |
|------|--------|-------|
| `lib/theme/app_colors.dart` | **NEW** — Color constants | 1 |
| `lib/theme/app_theme.dart` | **NEW** — Theme builder | 3 |
| `lib/theme/palette.dart` | Rewrite — keep extensions, remove tinted surfaces | 3 |
| `lib/widgets/ui_helpers.dart` | Rewrite — remove old helpers, keep sectionTitle | 3 |
| `lib/widgets/display_text.dart` | **NEW** — Large time display | 2 |
| `lib/widgets/primary_button.dart` | **NEW** — Primary action button | 2 |
| `lib/widgets/secondary_button.dart` | **NEW** — Secondary button | 2 |
| `lib/widgets/preset_grid.dart` | **NEW** — Preset duration grid with hierarchy | 2 |
| `lib/widgets/settings_row.dart` | **NEW** — Settings row component | 2 |
| `lib/widgets/toggle_switch.dart` | **NEW** — Custom toggle | 2 |
| `lib/widgets/section_header.dart` | **NEW** — Section label | 2 |
| `lib/widgets/bottom_nav_bar.dart` | **NEW** — Custom bottom nav | 7 |
| `lib/widgets/clock_panel.dart` | Full rewrite | 4 |
| `lib/widgets/timer_panel.dart` | Full rewrite | 5 |
| `lib/widgets/stopwatch_panel.dart` | Full rewrite | 6 |
| `lib/widgets/timer_ring.dart` | Refine — remove glow/shadow, thinner stroke | 5 |
| `lib/widgets/fullscreen_focus_view.dart` | Refine — new design language | 10 |
| `lib/widgets/fullscreen_stopwatch_view.dart` | Refine — new design language | 11 |
| `lib/widgets/settings_panel.dart` | Restyle as bottom sheet | 9 |
| `lib/main.dart` | Major — new theme, new nav, simplified AppBar | 3, 7, 8 |
| `lib/widgets/preset_chip_bar.dart` | Delete (replaced by preset_grid) | 13 |

## What Does NOT Change

- All service files (`lib/services/*`)
- All model files (`lib/models/*`)
- All l10n files (`lib/l10n/*`)
- All feature files (`lib/features/*`)
- State variables and business logic in `_MainScreenState`
- Timer/stopwatch/clock behavior and functionality
- Asset files

---

## Implementation Order

1. **Phase 1–2**: Create design system + shared components (foundation)
2. **Phase 3**: Rewrite theme + palette (breaks existing styling temporarily)
3. **Phase 4**: Clock screen (simplest, validates design system)
4. **Phase 5**: Timer screen (most complex, validates all components)
5. **Phase 6**: Stopwatch screen (reuses patterns from timer)
6. **Phase 7–8**: Bottom nav + AppBar (navigation polish)
7. **Phase 9**: Settings panel restyle
8. **Phase 10–11**: Fullscreen views
9. **Phase 12**: Responsive constraints
10. **Phase 13**: Cleanup and verification
