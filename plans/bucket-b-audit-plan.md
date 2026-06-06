# Bucket B — Deep Technical Audit Plan

## Overview

Bucket B is a systematic audit of app reliability, correctness, and quality. It covers 5 areas with specific findings identified through code review.

## Priority: VERY HIGH — Reliability & Persistence

---

## B1: Sleep Mode Verification

### Area
[`main.dart`](lib/main.dart) — lines 1889-1978 (`_isNightTime`, `_isSpeechMutedForSleep`, `_startNightIdleTimerIfNeeded`, `_scheduleNightResumeAnnouncement`, `_handleNightUsageStateChange`)

### Findings to Address

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | `_scheduleNightResumeAnnouncement()` calls `timeToWords()` which calls `getPreferredVoice()` — during sleep, TTS may not be initialized, risking empty/corrupt speech | Medium | Guard with TTS ready check or skip announcement if TTS not ready |
| 2 | Toggling `muteSpeechAfterMidnight` OFF while night is active leaves `autoNightMuteActive` potentially stale if `_isNightTime()` returns true but mute is disabled | Low | Reset `autoNightMuteActive = false` when mute is disabled in `onMuteSpeechAfterMidnightChanged` — already handled correctly in current code |
| 3 | The 5-minute idle timer only fires on lifecycle pause/inactive. If user leaves app open on timer tab, auto-mute never activates even during sleep window | Medium | Add periodic check (e.g., timer tick) or check on display tick |
| 4 | Midnight crossing works correctly — `_isNightTime()` handles `sleepStart > sleepEnd` range | OK | No change needed |

### Action Items
- [ ] Add auto-mute check to display tick (250ms) so it activates even when app is open
- [ ] Verify TTS readiness before night resume announcement

---

## B2: Reliability Audit

### Area
Boot: [`BootReceiver.kt`](android/app/src/main/kotlin/com/atherpulse/solasflow/BootReceiver.kt)
Service: [`main.dart`](lib/main.dart) lines 791-888 (foreground init), [`ForegroundNotificationService`](lib/services/foreground_notification_service.dart)
Speech: [`drainQueue()`](lib/main.dart:1790), gap enforcement in speech methods
Tests: [`timer_service_test.dart`](test/services/timer_service_test.dart)

### Findings to Address

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | **BootReceiver launches Activity without checking Android 12+ restrictions.** On Android 12+, starting an Activity from `BOOT_COMPLETED` broadcast is blocked unless the app has an enabled accessibility service or is exempted. The `AutoStartAccessibilityService` exists for this, but users must enable it manually with no onboarding. | HIGH | Add onboarding prompt for accessibility service on first boot / settings. Verify BootReceiver compatibility via `startForegroundService` intent instead. |
| 2 | **Speech queue gap race condition.** Each speak method (`speakClock`, `speakTimerMessage`, `_speakStopwatchMessage`, `_speakGoalReminderMessage`) independently computes a 10-second gap against `last*Spoke` timestamps. If two speech types fire within the same event loop tick, both compute the gap using the same `nowMs`, both schedule a delayed `Future.delayed`, and both add to queue — causing potential out-of-order playback. | MEDIUM | Centralize gap enforcement into a single speech scheduler method rather than duplicating the logic 4 times |
| 3 | **Notification sync throttle** (4:1 idle ratio, 100ms min interval) is correct but `_syncForegroundNotification` is called on every timer tick and stopwatch tick — this is 1/sec and 20/sec respectively. The throttle handles this but it's wasteful. | LOW | Reduce stopwatch tick sync if state hasn't changed |
| 4 | **Foreground health check runs unconditionally** even when all services are stopped (line 882 checks and returns early). The Timer is never cancelled. | LOW | Cancel foreground health timer when no service is active |
| 5 | **No unit tests for:** sleep mode behavior, foreground notification state, speech queue draining, gap enforcement logic | MEDIUM | Add tests for these critical paths |
| 6 | **`_showTimerFinishedDialog`** ringtone looping: `playAlarm(looping: true)` plays for exactly 5 seconds then stopped. If user selects a preset quickly (<5s), the stop() call in `_startTimerFromMinutes` handles it. If dialog takes longer, sound stops naturally. | OK | Works correctly |
| 7 | **TimerService.tick** announces at minute boundaries where `secs == 0 && nextSeconds != 0`. At `60:00`, it announces "60 minutes remaining" then immediately finishes. The announcement says "60 minutes" which is correct but "60 minutes remaining" when 0 seconds remain is slightly misleading. | LOW | Fix: at exact minute boundary where remaining == announceEvery, announce "X minutes left" |
| 8 | **Audio overlap**: `_applyAudioSettings()` restarts audio on every call even if the same track/volume is already playing | LOW | Track current audio state and skip if unchanged |

### Action Items
- [ ] Review BootReceiver for Android 12+ compatibility — consider using `startForegroundService` or companion widget update
- [ ] Add accessibility service onboarding prompt
- [ ] Centralize speech gap enforcement (deduplicate 4 methods into one)
- [ ] Cancel foreground health timer when all services stop
- [ ] Write unit tests for sleep mode, speech queue, notification state
- [ ] Track audio state to avoid redundant restarts

---

## B3: Announcement Speech Quality

### Area
English: [`main.dart`](lib/main.dart) lines 2238-2251 (timer), [`timer_service.dart`](lib/services/timer_service.dart:36) (clock), [`main.dart`](lib/main.dart:2138) (stopwatch)
Malayalam: [`malayalam_tts_service.dart`](lib/services/malayalam_tts_service.dart) (all announcements)
Goal reminders: [`main.dart`](lib/main.dart:1643-1675)

### Current vs Proposed

| Context | Current | Proposed | Priority |
|---------|---------|----------|----------|
| Timer finish | "Timer finished" | "Focus session complete" | Medium |
| 1 min remaining | "1 minute remaining" | "Final minute" | Low |
| N min remaining | "N minutes remaining" | "N minutes left" | Low |
| Stopwatch elapsed | "Elapsed X hours, Y minutes, Z seconds" | Keep (good) | OK |
| Goal reminder | "Goal reminder: $goal" | Just "$goal" | Low |
| Clock announcement | "3 o'clock AM" | Keep (good) | OK |
| Next timer | "Starting next timer: $minutes minutes" | "Starting $minutes-minute session" | Low |
| Malayalam timer finish | "സമയം തീർന്നു." | Keep (good) | OK |
| Malayalam timer remaining | "ഇനി $minutes മിനിറ്റ്." | Keep (good) | OK |

### Action Items
- [ ] Update English timer finish announcement
- [ ] Update English timer remaining phrasing
- [ ] Remove redundant "Goal reminder:" prefix
- [ ] Update chain next-timer announcement

---

## B4: Goal Section Review (Archived)

The Goals section has been removed from the Settings UI. All code remains in place:

- [`_buildGoalsTab()`](lib/main.dart:3178) — Full goals management screen
- [`goalReminderOn`](lib/main.dart:605) — State variable
- [`_restartGoalReminderTimer()`](lib/main.dart:1507) — Timer management
- [`_announceNextGoalReminder()`](lib/main.dart:1663) — Speech trigger
- Goal reminder gap enforcement in [`_speakGoalReminderMessage()`](lib/main.dart:1643)

### Recommendation

Keep archived. No further action unless feature is resurrected.

---

## B5: Voice Auto-Selection

### Area
[`VoiceSessionManager`](lib/services/voice_session_manager.dart), [`SpeechService.preferredVoice()`](lib/services/speech_service.dart:740), [`SpeechService.availableVoicesForSettings()`](lib/services/speech_service.dart:716)

### Assessment

The voice auto-selection logic is correct:
1. `VoiceSessionManager` caches the preferred voice per session
2. On language change, `resetSession()` clears cache and re-resolves
3. `preferredVoice()` uses `_voiceScore()` to rank by quality (neural > regional > standard)
4. `availableVoicesForSettings()` correctly filters by English/Malayalam mode

### Potential Concern

In `availableVoicesForSettings()` with `auto` mode (line 735), Malayalam voices are listed first, then English. This means in auto mode, a Malayalam voice would be selected if available. But `voiceListMode` can only be `english`, `malayalam`, or `auto` — and `auto` is normalized to `english` by `normalizeVoiceLanguageMode()` (line 648-660). So auto mode defaults to English voices. This is correct.

### Action Items
- [ ] No changes needed — verified as reliable
- [ ] Add a unit test for preferred voice selection with mock voices

---

## Implementation Order (Recommended)

```
Step 1: B2.1 — Fix BootReceiver Android 12+ compatibility
Step 2: B2.2 — Centralize speech gap enforcement (HARD)
Step 3: B2.3/B2.4 — Cancel health timer, track audio state
Step 4: B1.1/B1.3 — Add periodic night check, TTS guard
Step 5: B3 — Update announcement phrasing
Step 6: B2.5 — Add unit tests
```

Steps 1-2 are the highest impact. Steps 3-6 are lower risk.
