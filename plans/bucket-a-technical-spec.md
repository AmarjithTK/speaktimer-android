# Bucket A — Technical Implementation Specification

This document provides line-level detail for each of the 5 Bucket A improvements. Each step lists the exact files, fields, methods, and changes required.

---

## Step A1: Merge TTS Volume Features

### Files Changed
[`lib/core/pref_keys.dart`](lib/core/pref_keys.dart), [`lib/models/app_settings.dart`](lib/models/app_settings.dart), [`lib/services/settings_service.dart`](lib/services/settings_service.dart), [`lib/services/speech_service.dart`](lib/services/speech_service.dart), [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart), [`lib/main.dart`](lib/main.dart)

### 1.1 PrefKeys
Remove two old keys, add one new key:

```dart
// REMOVE (lines 6-7)
static const ttsMaxVolumeLockEnabled = 'TtsMaxVolumeLockEnabled';
static const ttsVolumeBoostEnabled = 'TtsVolumeBoostEnabled';

// ADD
static const maximumSpeechVolume = 'MaximumSpeechVolume';
```

### 1.2 AppSettings Model
Replace two booleans with one:

```dart
// REMOVE (lines 5-6)
final bool ttsMaxVolumeLockEnabled;
final bool ttsVolumeBoostEnabled;

// ADD (replacing above)
final bool maximumSpeechVolume;

// In constructor, REMOVE from required params:
//   required this.ttsMaxVolumeLockEnabled,
//   required this.ttsVolumeBoostEnabled,
// ADD:
//   required this.maximumSpeechVolume,
```

### 1.3 SettingsService.load()
```dart
// REMOVE (lines 74-77)
ttsMaxVolumeLockEnabled:
    prefs.getBool(PrefKeys.ttsMaxVolumeLockEnabled) ?? false,
ttsVolumeBoostEnabled:
    prefs.getBool(PrefKeys.ttsVolumeBoostEnabled) ?? false,

// ADD
maximumSpeechVolume:
    prefs.getBool(PrefKeys.maximumSpeechVolume) ?? false,
```

### 1.4 SettingsService.save()
```dart
// REMOVE (lines 140-147)
await prefs.setBool(
    PrefKeys.ttsMaxVolumeLockEnabled,
    settings.ttsMaxVolumeLockEnabled,
);
await prefs.setBool(
    PrefKeys.ttsVolumeBoostEnabled,
    settings.ttsVolumeBoostEnabled,
);

// ADD
await prefs.setBool(
    PrefKeys.maximumSpeechVolume,
    settings.maximumSpeechVolume,
);
```

### 1.5 SettingsService._runMigrations()
Bump schema version to 8. Add migration to read old keys and write new combined key:

```dart
// CHANGE at line 29:
static const int _currentSchemaVersion = 8;

// ADD after the version < 7 block (after line 298):
if (currentVersion < 8) {
    final oldBoost = prefs.getBool(PrefKeys.ttsVolumeBoostEnabled) ?? false;
    final oldLock = prefs.getBool(PrefKeys.ttsMaxVolumeLockEnabled) ?? false;
    final combined = oldBoost || oldLock;
    if (!prefs.containsKey(PrefKeys.maximumSpeechVolume)) {
        await prefs.setBool(PrefKeys.maximumSpeechVolume, combined);
    }
}
```

### 1.6 SpeechService.speakItem()
Modify the volume/max-lock logic at lines 824-845. Replace the two separate conditions with one:

```dart
// CURRENT (lines 824-845):
final ttsVolume = ttsVolumeBoostEnabled
    ? (speakVolume + 0.40).clamp(0.0, 1.0)
    : speakVolume.clamp(0.0, 1.0);

await flutterTts.setVolume(ttsVolume);

double? originalVolume;
if (ttsMaxVolumeLockEnabled && Platform.isAndroid) {
    try {
        await flutterTts.awaitSpeakCompletion(true);
    } catch (_) {}
    originalVolume = await _getMediaVolumeRatio();
    await _setMediaVolumeToMax();
}

await flutterTts.speak(item.text);

if (originalVolume != null) {
    await _setMediaVolumeRatio(originalVolume);
}

// REPLACE WITH:
final ttsVolume = maximumSpeechVolume
    ? (speakVolume + 0.40).clamp(0.0, 1.0)
    : speakVolume.clamp(0.0, 1.0);

await flutterTts.setVolume(ttsVolume);

double? originalVolume;
if (maximumSpeechVolume && Platform.isAndroid) {
    try {
        await flutterTts.awaitSpeakCompletion(true);
    } catch (_) {}
    originalVolume = await _getMediaVolumeRatio();
    await _setMediaVolumeToMax();
}

await flutterTts.speak(item.text);

if (originalVolume != null) {
    await _setMediaVolumeRatio(originalVolume);
}
```

Also update the method signature to accept `bool maximumSpeechVolume` instead of the two old params.

### 1.7 SettingsPanel
Remove two switches, add one. In the `build()` method's Audio card (lines 537-554):

```dart
// REMOVE these two blocks (lines 537-554):
_divider(context),
_switchRow(
    context,
    icon: Icons.volume_up_outlined,
    title: 'Max device volume for TTS',
    value: ttsMaxVolumeLockEnabled,
    onChanged: onTtsMaxVolumeLockEnabledChanged,
),
_divider(context),
_switchRow(
    context,
    icon: Icons.surround_sound_rounded,
    title: 'Boost announcement speech',
    subtitle: 'TTS only',
    value: ttsVolumeBoostEnabled,
    onChanged: onTtsVolumeBoostEnabledChanged,
),

// ADD one switch:
_divider(context),
_switchRow(
    context,
    icon: Icons.volume_up_rounded,
    title: 'Maximum Speech Volume',
    subtitle: 'Boost volume and lock device volume',
    value: maximumSpeechVolume,
    onChanged: onMaximumSpeechVolumeChanged,
),
```

Update the class constructor: remove `onTtsMaxVolumeLockEnabledChanged`, `onTtsVolumeBoostEnabledChanged`, `ttsMaxVolumeLockEnabled`, `ttsVolumeBoostEnabled`. Add `required bool maximumSpeechVolume` and `required ValueChanged<bool?> onMaximumSpeechVolumeChanged`.

### 1.8 main.dart

**State variables** — remove two, add one:
```dart
// REMOVE (lines 567-570):
/// Optional gain bump for TTS announcements only.
bool ttsVolumeBoostEnabled = false;
/// Optional hardware volume lock for TTS max
bool ttsMaxVolumeLockEnabled = false;

// ADD:
/// Combine volume boost + max device volume in one toggle
bool maximumSpeechVolume = false;
```

**_initPrefs()** — update at lines 1198-1199:
```dart
// REMOVE:
ttsMaxVolumeLockEnabled = settings.ttsMaxVolumeLockEnabled;
ttsVolumeBoostEnabled = settings.ttsVolumeBoostEnabled;

// ADD:
maximumSpeechVolume = settings.maximumSpeechVolume;
```

**_currentSettingsSnapshot()** — update at lines 1300-1301:
```dart
// REMOVE:
ttsMaxVolumeLockEnabled: ttsMaxVolumeLockEnabled,
ttsVolumeBoostEnabled: ttsVolumeBoostEnabled,

// ADD:
maximumSpeechVolume: maximumSpeechVolume,
```

**drainQueue()** — update the speakItem call at lines 1841-1842:
```dart
// REMOVE:
ttsMaxVolumeLockEnabled: ttsMaxVolumeLockEnabled,
ttsVolumeBoostEnabled: ttsVolumeBoostEnabled,

// ADD:
maximumSpeechVolume: maximumSpeechVolume,
```

Also update the retry block at lines 1859-1860 same way.

**_buildSettingsTab()** — update at lines 2943-2944 and 2992-3002:
```dart
// REMOVE props passed to SettingsPanel:
ttsMaxVolumeLockEnabled: ttsMaxVolumeLockEnabled,
ttsVolumeBoostEnabled: ttsVolumeBoostEnabled,
onTtsMaxVolumeLockEnabledChanged: (val) { ... },
onTtsVolumeBoostEnabledChanged: (val) { ... },

// ADD:
maximumSpeechVolume: maximumSpeechVolume,
onMaximumSpeechVolumeChanged: (val) {
    setState(() {
        maximumSpeechVolume = val ?? false;
        _lsSave();
    });
},
```

---

## Step A2: Settings Cleanup

### Files Changed
[`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart) — full section reorganization.

### New Section Order (in `build()` method)

```
┌──────────────────────────────────────────────┐
│ Settings                                       │
├──────────────────────────────────────────────┤
│ Audio & Speech                                 │
│  ├─ Background sound           [Rain] ▸       │
│  ├─ Noise volume               [Medium] ▸     │
│  ├─ Speech volume              [High] ▸       │
│  └─ Maximum Speech Volume               [⚙]  │
├──────────────────────────────────────────────┤
│ Voice                                          │
│  ├─ Speech engine              [Auto] ▸       │
│  │  └─ [engine status: System TTS ready]      │
│  ├─ Language list              [English] ▸    │
│  └─ Voice              [Veena - en-IN] ▸      │
├──────────────────────────────────────────────┤
│ Focus & Fullscreen                             │
│  ├─ App font size                   [1.0x] ═══│
│  ├─ Dark fullscreen                      [⚙] │
│  ├─ Dim fullscreen brightness            [⚙] │
│  └─ Start fullscreen landscape           [⚙] │
├──────────────────────────────────────────────┤
│ Sleep Mode                                     │
│  ├─ Enable sleep mode                    [⚙] │
│  │  ├─ Mode                     [Manual] ▸   │
│  │  ├─ Starts                  [12:00 AM] ▸  │
│  │  └─ Ends                     [6:00 AM] ▸  │
├──────────────────────────────────────────────┤
│ Goals                                          │
│  └─ [ Manage Goals ]                           │
├──────────────────────────────────────────────┤
│ System                                         │
│  ├─ Auto-start after reboot              [⚙] │
│  │  └─ [Accessibility service status]          │
│  ├─ Help / Working                        ▸  │
│  └─ Built by Amarjith TK            [ ↗ ]    │
└──────────────────────────────────────────────┘
```

### Detailed Changes to settings_panel.dart

**Constructor** — no parameter changes needed; all existing props remain. The section headers and card contents are reordered.

**Section headers** — Use existing `_sectionTitle()` helper. Replace:
- `_sectionTitle(context, 'Audio')` → `_sectionTitle(context, 'Audio & Speech')`
- `_sectionTitle(context, 'Appearance')` → `_sectionTitle(context, 'Focus & Fullscreen')`
- Move `_sectionTitle(context, 'Sleep mode')` after Focus & Fullscreen
- Move `_sectionTitle(context, 'Goals')` after Sleep Mode
- Combine `_sectionTitle(context, 'Auto-start')` + `_sectionTitle(context, 'About')` under a single `_sectionTitle(context, 'System')`

**Audio & Speech card** — Contains:
1. Background sound selector (existing)
2. Noise volume selector (existing)
3. Speech volume selector (existing)
4. Maximum Speech Volume switch (new from A1)

**Voice card** — keep exactly as-is (lines 556-616)

**Focus & Fullscreen card** — Keep App font size slider, Dark fullscreen, Dim brightness, Landscape start switches. Remove from old "Appearance" section (lines 617-682).

**Sleep Mode card** — Keep exactly as-is (lines 683-727)

**Goals section** — Keep the Manage Goals button (lines 728-753)

**System section** — New combined section:
```dart
_sectionTitle(context, 'System'),
_card(context, [
    // Auto-start switch (from lines 755-788)
    SwitchListTile(
        value: accessibilityEnabled,
        onChanged: (val) => onOpenAccessibility?.call(),
        ...
    ),
    _divider(context),
    // Help button (NEW — previously a separate button)
    ListTile(
        leading: Icon(Icons.help_outline_rounded, color: cs.primary, size: 20),
        title: Text('Help / Working', ...),
        trailing: Icon(Icons.chevron_right_rounded, ...),
        onTap: onOpenHelp,
    ),
    _divider(context),
    // About card (from lines 790-832)
    ListTile(
        leading: Icon(Icons.info_outline_rounded, ...),
        title: Text('Built by Amarjith TK', ...),
        subtitle: Text('Atherpulse Technologies', ...),
        trailing: Icon(Icons.open_in_new_rounded, ...),
        onTap: () async { ... },
    ),
]),
```

Remove the old standalone "About" card at the bottom. Remove the old "Auto-start" standalone card.

---

## Step A3: Unify Card Layout

### Files Changed
[`lib/widgets/timer_panel.dart`](lib/widgets/timer_panel.dart), [`lib/widgets/stopwatch_panel.dart`](lib/widgets/stopwatch_panel.dart)

### Reference: ClockCard (clock_panel.dart lines 198-286)
Clock uses a gradient Container with:
- `LinearGradient` from `cs.primary` to `cs.primary.withAlpha(200)`
- `BorderRadius.circular(18)`
- "CURRENT TIME" label (`cs.onPrimary.withValues(alpha: 0.7)`)
- Large time display (`fontSize: 48`, `FontWeight.w900`, `cs.onPrimary`)
- "Tap for fullscreen" hint at bottom

### A3.1 Timer Panel — Replace `_timerCircle()`

**Current** (lines 239-377): Uses `_TimerRingPainter` CustomPainter with a circular progress ring, "Remaining time" label, MM:SS display with centiseconds.

**New implementation**: Replace `_timerCircle()` with `_timeCard()` using the same gradient pattern as Clock:

```dart
Widget _timeCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timerParts = _splitTimer(timerValue);
    
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onFullscreenPressed,
        onDoubleTap: onFullscreenImmersivePressed,
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                children: [
                    Text(
                        'REMAINING TIME',
                        style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                        ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Text(
                                    timerParts.$1,
                                    style: TextStyle(
                                        color: cs.onPrimary,
                                        fontSize: 48,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                ),
                                Text(
                                    ':',
                                    style: TextStyle(
                                        color: cs.onPrimary,
                                        fontSize: 46,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                ),
                                Text(
                                    timerParts.$2,
                                    style: TextStyle(
                                        color: cs.onPrimary,
                                        fontSize: 48,
                                        height: 1,
                                        fontWeight: FontWeight.w900,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                ),
                                if (timerParts.$3 != null)
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                            '.${timerParts.$3}',
                                            style: TextStyle(
                                                color: cs.onPrimary.withValues(alpha: 0.7),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                fontFeatures: [FontFeature.tabularFigures()],
                                            ),
                                        ),
                                    ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                        _endLabel(context),
                        style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.82),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                        ),
                    ),
                ],
            ),
        ),
    );
}
```

The `_timerCircle()` calls in `build()` must be replaced with `_timeCard()`. The `_TimerRingPainter` class can remain in the file (it's still used in FullscreenFocusView if referenced, or it can be kept for future use). Remove it only if it's confirmed unused.

### A3.2 Stopwatch Panel — Replace `_elapsedCard()`

**Current** (lines 199-255): Uses a `Container` with `cs.surfaceContainerLow` background, border, "ELAPSED TIME" label, large text, and unit labels row.

**New implementation**: Replace `_elapsedCard()` with same gradient pattern:

```dart
Widget _elapsedCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onFullscreenPressed,
        onDoubleTap: onFullscreenImmersivePressed,
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                children: [
                    Text(
                        'ELAPSED TIME',
                        style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                        ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            elapsedValue,
                            style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 42,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                            ),
                        ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            _TimeUnitLabel(cs.onPrimary.withValues(alpha: 0.7), 'hr'),
                            const SizedBox(width: 30),
                            _TimeUnitLabel(cs.onPrimary.withValues(alpha: 0.7), 'min'),
                            const SizedBox(width: 30),
                            _TimeUnitLabel(cs.onPrimary.withValues(alpha: 0.7), 'sec'),
                            const SizedBox(width: 30),
                            _TimeUnitLabel(cs.onPrimary.withValues(alpha: 0.7), 'ms'),
                        ],
                    ),
                ],
            ),
        ),
    );
}
```

The `_TimeUnitLabel` widget at line 574 needs its constructor updated — currently takes `Color color` as positional param. Either keep as-is (works since `cs.onPrimary.withValues(alpha: 0.7)` is a Color) or update it.

---

## Step A4: Make Timer Default Tab

### Files Changed
[`lib/main.dart`](lib/main.dart) — one line change.

### Change
Line 506:
```dart
// CURRENT:
int currentTabIndex = 0;

// CHANGE TO:
int currentTabIndex = 1;
```

This is the only change needed. The NavigationBar already has Timer at index 1. All tab switching logic uses `setState(() { currentTabIndex = index; })` which respects the initial value.

---

## Step A5: Global Speech Master Toggle

### Files Changed
[`lib/core/pref_keys.dart`](lib/core/pref_keys.dart), [`lib/models/app_settings.dart`](lib/models/app_settings.dart), [`lib/models/foreground_notification_state.dart`](lib/models/foreground_notification_state.dart), [`lib/services/settings_service.dart`](lib/services/settings_service.dart), [`lib/main.dart`](lib/main.dart), [`lib/widgets/settings_panel.dart`](lib/widgets/settings_panel.dart)

### 5.1 PrefKeys
```dart
// ADD after line 7:
static const speechMasterOn = 'SpeechMasterOn';
```

### 5.2 AppSettings
```dart
// ADD after appFontSizeMultiplier field:
final bool speechMasterOn;

// ADD to constructor:
required this.speechMasterOn,
```

### 5.3 SettingsService.load()
```dart
// ADD after appFontSizeMultiplier line:
speechMasterOn: prefs.getBool(PrefKeys.speechMasterOn) ?? true,
```

### 5.4 SettingsService.save()
```dart
// ADD after appFontSizeMultiplier line:
await prefs.setBool(PrefKeys.speechMasterOn, settings.speechMasterOn);
```

### 5.5 ForegroundNotificationState
Check the model first, then add a button. Let me read it.

### 5.6 main.dart — State Variable
```dart
// ADD with other prefs state (~line 570):
/// Global speech on/off — when off, suppresses ALL speech
bool speechMasterOn = true;
```

### 5.7 main.dart — Modify _isSpeechMutedForSleep()
This is the critical gate. Currently at line 1968:
```dart
// CURRENT:
bool _isSpeechMutedForSleep() {
    if (!muteSpeechAfterMidnight) return false;
    if (!_isNightTime()) {
        autoNightMuteActive = false;
        return false;
    }
    if (nightMuteMode == 'manual') {
        return true;
    }
    return autoNightMuteActive;
}

// REPLACE WITH:
bool _isSpeechMutedForSleep() {
    // Global speech master toggle — when OFF, suppress everything
    if (!speechMasterOn) return true;
    
    if (!muteSpeechAfterMidnight) return false;
    if (!_isNightTime()) {
        autoNightMuteActive = false;
        return false;
    }
    if (nightMuteMode == 'manual') {
        return true;
    }
    return autoNightMuteActive;
}
```

This single change gates ALL speech because every speech path checks `_isSpeechMutedForSleep()`:
- `speak()` (line 1877)
- `speakClock()` (line 2018)
- `speakTimerMessage()` (line 2070)
- `_speakStopwatchMessage()` (line 2157)
- `_speakGoalReminderMessage()` (line 1643)
- `drainQueue()` (line 1790)

### 5.8 main.dart — _initPrefs()
```dart
// ADD in the setState block after appFontSizeMultiplier:
speechMasterOn = settings.speechMasterOn;
```

### 5.9 main.dart — _currentSettingsSnapshot()
```dart
// ADD:
speechMasterOn: speechMasterOn,
```

### 5.10 main.dart — Widget State Persistence
Update `_writeWidgetState()` at line 1345:
```dart
// ADD inside the method:
await prefs.setBool('widget_speech_master', speechMasterOn);
```

### 5.11 main.dart — Notification Button Handler
In `_onReceiveTaskData()` at line 1105, add a new case:
```dart
case 'btn_speech_master':
    setState(() {
        speechMasterOn = !speechMasterOn;
        if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
        }
        _lsSave();
    });
    _syncForegroundNotification(force: true);
    break;
```

### 5.12 main.dart — Widget Action Handler
In `_handleWidgetAction()` at line 1370, add new case after line 1471:
```dart
case 'toggle_speech_master':
    setState(() {
        speechMasterOn = !speechMasterOn;
        if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
        }
        _lsSave();
    });
    _syncForegroundNotification(force: true);
    break;
```

### 5.13 main.dart — Quick Action Handler
In `_handleQuickAction()` at line 950, add:
```dart
case 'toggle_speech_master':
    setState(() {
        speechMasterOn = !speechMasterOn;
        if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
        }
        _lsSave();
    });
    _syncForegroundNotification(force: true);
    break;
```

### 5.14 ForegroundNotificationState — Add speechMasterOn field + button

[`ForegroundNotificationState`](lib/models/foreground_notification_state.dart) needs:

1. New field `speechMasterOn` (bool)
2. New `NotificationButton` in ALL three button lists

```dart
// ADD field after clockSpeechOn:
final bool speechMasterOn;

// ADD to constructor:
required this.speechMasterOn,
```

In the `buttons` getter, add the speech master button to each list. Example — idle state buttons (lines 61-68):
```dart
return [
    const NotificationButton(id: 'btn_stopwatch_toggle', text: 'Start SW'),
    NotificationButton(
        id: 'btn_clock_speech',
        text: clockSpeechOn ? 'Clock Speech ON' : 'Clock Speech OFF',
    ),
    NotificationButton(
        id: 'btn_speech_master',
        text: speechMasterOn ? 'Speech ON' : 'Speech OFF',
    ),
    const NotificationButton(id: 'btn_exit', text: 'Exit'),
];
```

Also update `_foregroundState()` in main.dart (line 842) to pass `speechMasterOn`:
```dart
return ForegroundNotificationState(
    ...
    clockSpeechOn: clockOn,
    speechMasterOn: speechMasterOn,  // ADD
);
```

### 5.15 SettingsPanel
Add `speechMasterOn` toggle to the **Audio & Speech** section as the first item (before Background sound):
```dart
_switchRow(
    context,
    icon: Icons.volume_off_rounded,
    title: 'Speech',
    subtitle: speechMasterOn ? 'All speech on' : 'All speech off',
    value: speechMasterOn,
    onChanged: onSpeechMasterOnChanged,
),
```

### 5.16 SettingsPanel Constructor Props
Add:
```dart
required final bool speechMasterOn;
required final ValueChanged<bool?> onSpeechMasterOnChanged;
```

### 5.17 main.dart — Building Settings Tab
Pass the new props:
```dart
speechMasterOn: speechMasterOn,
onSpeechMasterOnChanged: (val) {
    setState(() {
        speechMasterOn = val ?? true;
        if (!speechMasterOn) {
            speechQueue.clear();
            unawaited(flutterTts.stop());
        }
        _lsSave();
    });
},
```

### 5.18 Notification Service Integration
Need to add the global speech toggle button to the persistent notification. Read [`foreground_notification_state.dart`](lib/models/foreground_notification_state.dart) to understand the button structure, then add a new button that sends `btn_speech_master` action.

```dart
// Likely add to the buttons list:
NotificationButton(
    id: 'btn_speech_master',
    text: speechMasterOn ? 'Mute' : 'Speak',
),
```

### 5.19 Widget Button Integration

The widget action `toggle_speech_master` is handled in step 5.12 in `_handleWidgetAction()`.

**Android native side** — In the widget layout XML, add a new button that sends `toggle_speech_master` via the existing MethodChannel. The widget state key `widget_speech_master` (written in step 5.10) is read by the widget to display correct on/off state.

**Quick actions** — Optionally add `toggle_speech_master` to the shortcut items in `_initQuickActions()` (line 995):
```dart
const ShortcutItem(
    type: 'toggle_speech_master',
    localizedTitle: 'Toggle Speech',
    icon: 'icon_speech',
),
```

---

## Dependency Graph

```
A1 (TTS Merge) ──> A2 (Settings Cleanup) ──> A5 (Speech Toggle)
                      ↑ uses updated settings panel
                      
A3 (Card Layout) ──── independent ────> A5 (if toggle shown in panels)
                      
A4 (Timer Tab) ───── independent

Suggested Implementation Order:

A4 → A1 → A3 → A2 → A5
(timer default) (model changes) (visual) (settings UI) (speech gate)
```

## Risk Assessment

| Step | Risk Level | Mitigation |
|------|-----------|------------|
| A1 TTS Merge | Low | Boolean replacement; old fields removed cleanly; migration handles existing users |
| A2 Settings Cleanup | Low | Pure UI reorganization; no logic changes |
| A3 Card Layout | Medium | Visual change only; ring painter removed from main panel but kept for fullscreen; gradient matches Clock |
| A4 Timer Default | Trivial | Single line change |
| A5 Speech Toggle | Low-Medium | New feature; `_isSpeechMutedForSleep()` is the single gate; notification/widget integration needs native-side changes |
