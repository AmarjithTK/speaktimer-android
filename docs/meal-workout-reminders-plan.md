# Meal & Workout Reminder Notifications — Feature Plan

## Overview

This document describes the **product plan** for adding scheduled meal and workout reminders to the LIFER app. Because LIFER already runs as a persistent foreground service, these reminders can fire reliably without any additional "always-on" infrastructure.

---

## Problem Statement

Users want the app to:
1. Remind them to eat **breakfast**, **lunch**, and **dinner** at custom times they set.
2. Remind them to work out at a custom time they set.
3. Show a **confirmation popup** (action notification) when the time arrives.
4. **Repeat** that popup every **30 minutes** until the user taps **"Yes, done"**.

---

## User Stories

| ID | As a user, I want to… | So that… |
|----|----------------------|----------|
| US-1 | Set a custom time for each meal (breakfast / lunch / dinner) | I am reminded to eat at my preferred times every day |
| US-2 | Set a custom time for my workout | I never forget to exercise |
| US-3 | Enable or disable each reminder independently | I can skip reminders I don't need |
| US-4 | See a persistent, dismissable notification with a "Yes, done" action button | I can confirm completion directly from the notification shade |
| US-5 | Have the reminder repeat every 30 min until I confirm it | I am nudged even if I initially dismiss the notification |
| US-6 | Have the reminder reset automatically the next day | I don't need to reconfigure anything daily |

---

## Feature Scope (MVP)

### In-scope
- Four reminder types: **Breakfast**, **Lunch**, **Dinner**, **Workout**
- Per-reminder **time picker** in the Settings tab
- Per-reminder **enable/disable** toggle
- Confirmation-style notification with **"Yes, done"** action
- **30-minute re-fire** loop until confirmed
- Daily automatic reset at midnight

### Out-of-scope (future)
- Custom reminder labels / adding arbitrary reminder types
- Snooze granularity other than 30 minutes
- Reminder history / analytics
- Sound customisation per reminder type (falls back to `notify.mp3`)

---

## UX Flow

```
User opens Settings tab
    └─ Taps "Reminders" section (new)
         ├─ Breakfast  [toggle ON/OFF]  [Time: 08:00 AM]  [edit pencil]
         ├─ Lunch      [toggle ON/OFF]  [Time: 01:00 PM]  [edit pencil]
         ├─ Dinner     [toggle ON/OFF]  [Time: 07:30 PM]  [edit pencil]
         └─ Workout    [toggle ON/OFF]  [Time: 06:00 AM]  [edit pencil]

                     ↓ tap edit pencil
               TimePickerDialog (Material 3)
                     ↓ tap OK
               Saved → scheduled via flutter_local_notifications

                     ↓ scheduled time arrives
         Notification: "🍽️ Time for Breakfast!"
                       [Yes, done]
                     ↓ not tapped within 30 min
         Notification (repeat): "🍽️ Breakfast reminder (missed)"
                       [Yes, done]
                     ↓ user taps "Yes, done"
         Notification dismissed → no more repeats until tomorrow
```

---

## Architecture Overview

```
lib/
├── models/
│   └── app_settings.dart          ← add 8 new fields (enabled + time per reminder)
├── services/
│   ├── settings_service.dart      ← persist / load new fields
│   └── reminder_service.dart      ← NEW: schedule, cancel, re-fire logic
├── widgets/
│   └── settings_panel.dart        ← new "Reminders" section with time pickers
└── main.dart                      ← initialise ReminderService; handle
                                       notification action callbacks
android/app/src/main/
└── AndroidManifest.xml            ← add SCHEDULE_EXACT_ALARM + RECEIVE_BOOT_COMPLETED
                                       permissions; register BootReceiver
```

### Key dependencies (already in pubspec.yaml)
| Package | Role |
|---------|------|
| `flutter_local_notifications ^21` | Schedule & display confirmation notifications |
| `shared_preferences` | Persist reminder on/off & time settings |
| `flutter_foreground_task ^9` | Ensures the app process stays alive so timers can fire |

No new dependencies are required for the MVP.

---

## Data Model Changes

Two new fields per reminder type will be added to `AppSettings`:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `breakfastReminderOn` | `bool` | `false` | Enable breakfast reminder |
| `breakfastReminderTime` | `String` | `"08:00"` | HH:mm 24-hour format |
| `lunchReminderOn` | `bool` | `false` | Enable lunch reminder |
| `lunchReminderTime` | `String` | `"13:00"` | HH:mm 24-hour format |
| `dinnerReminderOn` | `bool` | `false` | Enable dinner reminder |
| `dinnerReminderTime` | `String` | `"19:30"` | HH:mm 24-hour format |
| `workoutReminderOn` | `bool` | `false` | Enable workout reminder |
| `workoutReminderTime` | `String` | `"06:00"` | HH:mm 24-hour format |

Additionally, a **transient** in-memory map tracks which reminders have been confirmed today (never persisted to disk; resets on app restart / midnight):

```dart
Map<ReminderType, bool> _confirmedToday = {};
```

---

## Notification Design

### Notification IDs

| Reminder | Notification ID |
|----------|----------------|
| Breakfast | 101 |
| Lunch | 102 |
| Dinner | 103 |
| Workout | 104 |

IDs are well above the foreground service notification ID (which is 1) to avoid collisions.

### Notification Content

| Field | Example |
|-------|---------|
| Title | `"🍳 Time for Breakfast!"` |
| Body | `"Tap Done when you've eaten."` |
| Action button | `"✅ Yes, done"` |
| Ongoing | `false` (dismissable by swipe) |
| Auto-cancel | `false` (so the action button works) |

### Repeat Logic

1. At the scheduled time, `ReminderService` fires notification ID `N`.
2. A **30-minute delayed re-schedule** is immediately registered.
3. When the user taps "✅ Yes, done", a `didReceiveNotificationResponse` callback cancels the pending re-schedule and marks the reminder as confirmed for today.
4. At midnight (or next app launch), all confirmation states reset and new schedules are registered for the next occurrence.

---

## Permissions Required

### Android
```xml
<!-- Required for exact alarms on API 31+ -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- Reschedule on device reboot -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

A `BootReceiver` (Kotlin) will re-register all active reminders after a device restart because scheduled notifications do not survive reboots.

### iOS
No new entitlements are needed; `flutter_local_notifications` handles UNUserNotificationCenter authorisation at runtime.

---

## Settings UI Wireframe (text)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏰  Reminders
━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🍳 Breakfast          [●]
     08:00 AM           [✏️]

  🥗 Lunch              [●]
     1:00 PM            [✏️]

  🍽️ Dinner             [ ]
     7:30 PM            [✏️]

  🏋️ Workout            [●]
     6:00 AM            [✏️]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Tapping the pencil icon opens Flutter's built-in `showTimePicker()` Material 3 dialog.

---

## Milestones

| # | Milestone | Estimated effort |
|---|-----------|-----------------|
| 1 | Data model + settings persistence | 1 h |
| 2 | `ReminderService` — schedule, cancel, re-fire | 3 h |
| 3 | Settings UI (toggle + time picker) | 2 h |
| 4 | Android manifest + BootReceiver | 1 h |
| 5 | `main.dart` wiring + notification callbacks | 1 h |
| 6 | Manual QA on Android 13, 14 | 1 h |
| **Total** | | **~9 h** |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| `SCHEDULE_EXACT_ALARM` denied on Android 12+ | Fall back to inexact alarm; show in-app prompt to grant permission from battery settings |
| Notification silent after battery optimisation kills foreground service | `flutter_foreground_task` keeps the service alive; register reminder directly via `AlarmManager` as a backup |
| Re-fire loop never ends if app is force-stopped | Store "confirmed today" flag in SharedPreferences with date; on restart, check if today's reminder was already confirmed |
| iOS background notification restrictions | Use `UNCalendarNotificationTrigger` via `flutter_local_notifications`; iOS will deliver if app has notification permission |

---

## Related Files

- [`docs/meal-workout-reminders-implementation.md`](meal-workout-reminders-implementation.md) — full implementation guide with code snippets
- [`lib/models/app_settings.dart`](../lib/models/app_settings.dart)
- [`lib/services/settings_service.dart`](../lib/services/settings_service.dart)
- [`lib/widgets/settings_panel.dart`](../lib/widgets/settings_panel.dart)
- [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)
