# Meal & Workout Reminder Notifications — Implementation Guide

> **Prerequisite**: Read [`meal-workout-reminders-plan.md`](meal-workout-reminders-plan.md) before this document.

This guide walks through every code change needed to ship the feature end-to-end, in the order you should implement them.

---

## 1  Data Model — `lib/models/app_settings.dart`

### 1a  Add `ReminderType` enum

Add at the top of the file (or in a new `lib/models/reminder_type.dart`):

```dart
enum ReminderType {
  breakfast,
  lunch,
  dinner,
  workout;

  int get notificationId {
    switch (this) {
      case ReminderType.breakfast: return 101;
      case ReminderType.lunch:     return 102;
      case ReminderType.dinner:    return 103;
      case ReminderType.workout:   return 104;
    }
  }

  String get label {
    switch (this) {
      case ReminderType.breakfast: return 'Breakfast';
      case ReminderType.lunch:     return 'Lunch';
      case ReminderType.dinner:    return 'Dinner';
      case ReminderType.workout:   return 'Workout';
    }
  }

  String get emoji {
    switch (this) {
      case ReminderType.breakfast: return '🍳';
      case ReminderType.lunch:     return '🥗';
      case ReminderType.dinner:    return '🍽️';
      case ReminderType.workout:   return '🏋️';
    }
  }
}
```

### 1b  Extend `AppSettings` class

Add 8 new fields to the `AppSettings` immutable value class and update `copyWith`, `==`, and `hashCode`:

```dart
// --- Reminders ---
final bool breakfastReminderOn;
final String breakfastReminderTime; // "HH:mm" 24-h format
final bool lunchReminderOn;
final String lunchReminderTime;
final bool dinnerReminderOn;
final String dinnerReminderTime;
final bool workoutReminderOn;
final String workoutReminderTime;
```

Default values:

| Field | Default |
|-------|---------|
| `breakfastReminderOn` | `false` |
| `breakfastReminderTime` | `"08:00"` |
| `lunchReminderOn` | `false` |
| `lunchReminderTime` | `"13:00"` |
| `dinnerReminderOn` | `false` |
| `dinnerReminderTime` | `"19:30"` |
| `workoutReminderOn` | `false` |
| `workoutReminderTime` | `"06:00"` |

### 1c  Helper accessor

Add a convenience method to look up settings by `ReminderType`:

```dart
bool reminderOn(ReminderType type) {
  switch (type) {
    case ReminderType.breakfast: return breakfastReminderOn;
    case ReminderType.lunch:     return lunchReminderOn;
    case ReminderType.dinner:    return dinnerReminderOn;
    case ReminderType.workout:   return workoutReminderOn;
  }
}

String reminderTime(ReminderType type) {
  switch (type) {
    case ReminderType.breakfast: return breakfastReminderTime;
    case ReminderType.lunch:     return lunchReminderTime;
    case ReminderType.dinner:    return dinnerReminderTime;
    case ReminderType.workout:   return workoutReminderTime;
  }
}

AppSettings withReminder(ReminderType type, {bool? on, String? time}) {
  return copyWith(
    breakfastReminderOn:   type == ReminderType.breakfast ? (on   ?? breakfastReminderOn)   : breakfastReminderOn,
    breakfastReminderTime: type == ReminderType.breakfast ? (time ?? breakfastReminderTime) : breakfastReminderTime,
    lunchReminderOn:       type == ReminderType.lunch     ? (on   ?? lunchReminderOn)       : lunchReminderOn,
    lunchReminderTime:     type == ReminderType.lunch     ? (time ?? lunchReminderTime)     : lunchReminderTime,
    dinnerReminderOn:      type == ReminderType.dinner    ? (on   ?? dinnerReminderOn)      : dinnerReminderOn,
    dinnerReminderTime:    type == ReminderType.dinner    ? (time ?? dinnerReminderTime)    : dinnerReminderTime,
    workoutReminderOn:     type == ReminderType.workout   ? (on   ?? workoutReminderOn)     : workoutReminderOn,
    workoutReminderTime:   type == ReminderType.workout   ? (time ?? workoutReminderTime)   : workoutReminderTime,
  );
}
```

---

## 2  Settings Persistence — `lib/services/settings_service.dart`

### 2a  Add preference keys

Inside `PrefKeys` (or wherever other keys are defined):

```dart
static const breakfastReminderOn   = 'breakfastReminderOn';
static const breakfastReminderTime = 'breakfastReminderTime';
static const lunchReminderOn       = 'lunchReminderOn';
static const lunchReminderTime     = 'lunchReminderTime';
static const dinnerReminderOn      = 'dinnerReminderOn';
static const dinnerReminderTime    = 'dinnerReminderTime';
static const workoutReminderOn     = 'workoutReminderOn';
static const workoutReminderTime   = 'workoutReminderTime';
```

### 2b  Load (inside `load()`)

```dart
breakfastReminderOn:   prefs.getBool(PrefKeys.breakfastReminderOn)     ?? false,
breakfastReminderTime: prefs.getString(PrefKeys.breakfastReminderTime) ?? '08:00',
lunchReminderOn:       prefs.getBool(PrefKeys.lunchReminderOn)         ?? false,
lunchReminderTime:     prefs.getString(PrefKeys.lunchReminderTime)     ?? '13:00',
dinnerReminderOn:      prefs.getBool(PrefKeys.dinnerReminderOn)        ?? false,
dinnerReminderTime:    prefs.getString(PrefKeys.dinnerReminderTime)    ?? '19:30',
workoutReminderOn:     prefs.getBool(PrefKeys.workoutReminderOn)       ?? false,
workoutReminderTime:   prefs.getString(PrefKeys.workoutReminderTime)   ?? '06:00',
```

### 2c  Save (inside `save()`)

```dart
await prefs.setBool(PrefKeys.breakfastReminderOn,     settings.breakfastReminderOn);
await prefs.setString(PrefKeys.breakfastReminderTime, settings.breakfastReminderTime);
await prefs.setBool(PrefKeys.lunchReminderOn,         settings.lunchReminderOn);
await prefs.setString(PrefKeys.lunchReminderTime,     settings.lunchReminderTime);
await prefs.setBool(PrefKeys.dinnerReminderOn,        settings.dinnerReminderOn);
await prefs.setString(PrefKeys.dinnerReminderTime,    settings.dinnerReminderTime);
await prefs.setBool(PrefKeys.workoutReminderOn,       settings.workoutReminderOn);
await prefs.setString(PrefKeys.workoutReminderTime,   settings.workoutReminderTime);
```

---

## 3  Reminder Service — `lib/services/reminder_service.dart` (NEW FILE)

Create this file in full:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/reminder_type.dart'; // or wherever enum is defined

/// Notification channel used exclusively by meal/workout reminders.
const _kChannelId   = 'lifer_reminders';
const _kChannelName = 'Meal & Workout Reminders';
const _kActionDone  = 'reminder_done';

/// Re-fires a missed reminder this many minutes after it first fires.
const _kRepeatMinutes = 30;

/// SharedPreferences key that stores "confirmed today" info as a JSON-like string.
/// Format: "2024-03-15:breakfast,workout"
const _kConfirmedTodayKey = 'reminderConfirmedToday';

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final _notifications = FlutterLocalNotificationsPlugin();

  /// Call once at app startup, before scheduling any reminders.
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_lifer');
    const iosInit     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _notifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kChannelId,
            _kChannelName,
            description: 'Daily meal and workout reminders',
            importance: Importance.high,
          ),
        );
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Reschedule all reminders from [settings].
  /// Call whenever settings change or the app comes to the foreground.
  Future<void> applySettings(AppSettings settings) async {
    for (final type in ReminderType.values) {
      if (settings.reminderOn(type)) {
        await _scheduleNext(type, settings.reminderTime(type));
      } else {
        await cancel(type);
      }
    }
  }

  /// Cancel all pending notifications for [type].
  Future<void> cancel(ReminderType type) async {
    await _notifications.cancel(type.notificationId);
    await _notifications.cancel(_repeatId(type));
  }

  /// Cancel all reminder notifications.
  Future<void> cancelAll() async {
    for (final type in ReminderType.values) {
      await cancel(type);
    }
  }

  // ─── Internal helpers ──────────────────────────────────────────────────────

  /// Returns a secondary notification ID used for the 30-minute re-fire.
  int _repeatId(ReminderType type) => type.notificationId + 10;

  /// Parse "HH:mm" and return the next [DateTime] occurrence at that time.
  DateTime _nextOccurrence(String hhmm) {
    final parts = hhmm.split(':');
    final now   = DateTime.now();
    var target  = DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }

  Future<void> _scheduleNext(ReminderType type, String hhmm) async {
    // Do not reschedule if already confirmed today.
    if (await _isConfirmedToday(type)) return;

    final scheduledDate = _nextOccurrence(hhmm);
    await _notifications.zonedSchedule(
      type.notificationId,
      '${type.emoji} Time for ${type.label}!',
      'Tap "Done" once you\'re finished.',
      _toTZDateTime(scheduledDate),
      _buildDetails(type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: type.name,
    );
  }

  /// Schedule the 30-minute re-fire notification.
  Future<void> _scheduleRepeat(ReminderType type) async {
    final repeatAt = DateTime.now().add(Duration(minutes: _kRepeatMinutes));
    await _notifications.zonedSchedule(
      _repeatId(type),
      '${type.emoji} ${type.label} reminder (missed)',
      'You haven\'t confirmed yet. Tap "Done" when finished.',
      _toTZDateTime(repeatAt),
      _buildDetails(type),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: type.name,
    );
  }

  NotificationDetails _buildDetails(ReminderType type) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: 'Daily meal and workout reminders',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: false,
        ongoing: false,
        actions: [
          const AndroidNotificationAction(
            _kActionDone,
            '✅ Yes, done',
            cancelNotification: true,
            showsUserInterface: false,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: _kActionDone,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // ─── Notification response handler ─────────────────────────────────────────

  static void _onNotificationResponse(NotificationResponse response) {
    // Runs on background isolate — keep synchronous + no UI access.
    if (response.actionId == _kActionDone || response.notificationResponseType ==
        NotificationResponseType.selectedNotification) {
      final typeName = response.payload;
      if (typeName != null) {
        ReminderService.instance._handleConfirmed(
          ReminderType.values.firstWhere((t) => t.name == typeName),
        );
      }
    }
  }

  Future<void> _handleConfirmed(ReminderType type) async {
    await _notifications.cancel(_repeatId(type));
    await _markConfirmedToday(type);
  }

  // ─── Confirmed-today persistence ───────────────────────────────────────────
  // Stores "YYYY-MM-DD:type1,type2" in SharedPreferences.

  Future<bool> _isConfirmedToday(ReminderType type) async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_kConfirmedTodayKey) ?? '';
    return _parseConfirmed(raw).contains(type.name);
  }

  Future<void> _markConfirmedToday(ReminderType type) async {
    final prefs    = await SharedPreferences.getInstance();
    final existing = _parseConfirmed(prefs.getString(_kConfirmedTodayKey) ?? '');
    existing.add(type.name);
    final today = _todayString();
    await prefs.setString(_kConfirmedTodayKey, '$today:${existing.join(',')}');
  }

  Set<String> _parseConfirmed(String raw) {
    if (raw.isEmpty) return {};
    final parts = raw.split(':');
    if (parts.length != 2 || parts[0] != _todayString()) return {};
    return parts[1].split(',').toSet();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
           '${now.day.toString().padLeft(2, '0')}';
  }

  // Thin wrapper — replace with tz.TZDateTime if you add the `timezone` package.
  static dynamic _toTZDateTime(DateTime dt) => dt;
}
```

> **Note on `zonedSchedule` and timezones**: `flutter_local_notifications` v21 works best with the `timezone` package for `TZDateTime`. If the project already imports it (via `flutter_foreground_task`), use `tz.TZDateTime.from(dt, tz.local)`. The placeholder `_toTZDateTime` above should be replaced accordingly.

---

## 4  Settings UI — `lib/widgets/settings_panel.dart`

### 4a  Locate the correct insertion point

The Settings panel is built with a `ListView` of `ExpansionTile` / `ListTile` cards. Insert a new **Reminders** section after the existing **Goals** section.

### 4b  Add helper widget `_ReminderTile`

```dart
Widget _reminderTile(
  BuildContext context,
  AppSettings settings,
  ReminderType type,
  void Function(AppSettings) onChanged,
) {
  final isOn   = settings.reminderOn(type);
  final timeStr = settings.reminderTime(type);
  final parts  = timeStr.split(':');
  final tod    = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

  return ListTile(
    leading: Text(type.emoji, style: const TextStyle(fontSize: 22)),
    title: Text(type.label),
    subtitle: Text(tod.format(context)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time picker button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Change time',
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: tod,
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
                child: child!,
              ),
            );
            if (picked != null) {
              final hhmm =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              onChanged(settings.withReminder(type, time: hhmm));
            }
          },
        ),
        // Enable/disable switch
        Switch(
          value: isOn,
          onChanged: (value) {
            onChanged(settings.withReminder(type, on: value));
          },
        ),
      ],
    ),
  );
}
```

### 4c  Insert the section into `build()`

```dart
// ── Reminders Section ─────────────────────────────────────────────────
ExpansionTile(
  leading: const Icon(Icons.alarm),
  title: const Text('Reminders'),
  subtitle: const Text('Meal & workout notifications'),
  children: ReminderType.values.map((type) => _reminderTile(
    context, settings, type,
    (updated) {
      setState(() => _settings = updated);
      SettingsService.instance.save(updated);
      ReminderService.instance.applySettings(updated);
    },
  )).toList(),
),
```

---

## 5  Wire Up in `main.dart`

### 5a  Initialise `ReminderService`

In the `initState` / startup block of `_MainScreenState`, after `SettingsService` loads:

```dart
await ReminderService.instance.init();
await ReminderService.instance.applySettings(_settings);
```

### 5b  Re-apply on app resume

In `didChangeAppLifecycleState`:

```dart
case AppLifecycleState.resumed:
  await ReminderService.instance.applySettings(_settings);
  // ... existing foreground service sync
  break;
```

---

## 6  Android Manifest Changes — `android/app/src/main/AndroidManifest.xml`

### 6a  Add permissions

```xml
<!-- Exact alarms for meal/workout reminders (API 31+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- Re-register reminders after device reboot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 6b  Register BootReceiver

```xml
<receiver
    android:name=".ReminderBootReceiver"
    android:exported="true"
    android:enabled="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.LOCKED_BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

---

## 7  Android BootReceiver — `android/app/src/main/kotlin/com/example/speakertimer/ReminderBootReceiver.kt` (NEW)

```kotlin
package com.example.speakertimer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-launches the main activity silently on device reboot so that
 * Flutter's ReminderService can re-register all scheduled notifications.
 * The activity checks `Intent.ACTION_MAIN` vs reboot action to avoid
 * disrupting the user.
 */
class ReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.LOCKED_BOOT_COMPLETED"
        ) {
            val launch = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra("fromBootReceiver", true)
            }
            context.startActivity(launch)
        }
    }
}
```

In `MainActivity.kt`, add handling for the reboot extra if needed (e.g., skip full UI restore and go straight to background mode).

---

## 8  iOS Notification Category (Optional, Recommended)

To make the "✅ Yes, done" action button appear on iOS, register a UNNotificationCategory in AppDelegate:

```swift
// ios/Runner/AppDelegate.swift  (inside didFinishLaunchingWithOptions)
let doneAction = UNNotificationAction(
    identifier: "reminder_done",
    title: "✅ Yes, done",
    options: [.authenticationRequired]
)
let category = UNNotificationCategory(
    identifier: "reminder_done",
    actions: [doneAction],
    intentIdentifiers: [],
    options: []
)
UNUserNotificationCenter.current().setNotificationCategories([category])
```

---

## 9  Testing Checklist

| Test | Expected result |
|------|----------------|
| Enable Breakfast, set time 1 min from now | Notification fires in ~1 min |
| Ignore notification for 30 min | Re-fire notification appears |
| Tap "✅ Yes, done" | No more notifications for Breakfast today |
| Kill app, restart | Confirmed state persists; no duplicate notification |
| Reboot device | Reminders are re-registered after boot |
| Disable a reminder toggle | Pending notification is cancelled immediately |
| Change reminder time | New notification is scheduled at updated time |
| Set two reminders with overlapping times | Both fire independently |

---

## 10  File Change Summary

| File | Change type |
|------|------------|
| `lib/models/reminder_type.dart` | **New** — `ReminderType` enum |
| `lib/models/app_settings.dart` | **Modified** — 8 new fields + helpers |
| `lib/services/settings_service.dart` | **Modified** — persist/load 8 new keys |
| `lib/services/reminder_service.dart` | **New** — scheduling, cancellation, repeat logic |
| `lib/widgets/settings_panel.dart` | **Modified** — new "Reminders" `ExpansionTile` section |
| `lib/main.dart` | **Modified** — init + resume wiring |
| `android/app/src/main/AndroidManifest.xml` | **Modified** — 2 new permissions + BootReceiver registration |
| `android/app/src/main/kotlin/…/ReminderBootReceiver.kt` | **New** — Kotlin boot receiver |
| `ios/Runner/AppDelegate.swift` | **Modified** (optional) — iOS notification category |

---

## 11  Related Documents

- [`meal-workout-reminders-plan.md`](meal-workout-reminders-plan.md) — product plan, UX flow, risk register
