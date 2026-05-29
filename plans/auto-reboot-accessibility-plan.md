# Auto-Relaunch Across Reboots via Accessibility Service

To automatically relaunch the SolasFlow UI in the foreground immediately after a device restart, Android requires special handling because of strict background activity launch restrictions (Android 10+).

Using an **Accessibility Service** combined with a **Boot Completed Receiver** is a reliable workaround, as Accessibility services are granted exemptions to launch activities from the background. 

## Phase 1: Native Android Configuration

### 1. Add Required Permissions
Add the following to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### 2. Register Boot Receiver & Accessibility Service
In the `<application>` block of your `AndroidManifest.xml`, register both:

```xml
<!-- Listens for Device Boot -->
<receiver android:name=".BootReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>

<!-- Accessibility Service to bypass background launch restrictions -->
<service
    android:name=".AutoStartAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
</service>
```

### 3. Native Kotlin Implementations

**`BootReceiver.kt`**
Receives the boot event. From here, we can trigger the `MainActivity` directly since an enabled Accessibility service implies higher privileges, or start a foreground service that triggers the UI.
```kotlin
package com.atherpulse.solasflow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val launchIntent = Intent(context, MainActivity::class.java)
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            context.startActivity(launchIntent)
        }
    }
}
```

**`AutoStartAccessibilityService.kt`**
An empty placeholder service. Merely having it enabled by the user gives the app system exemptions for background starts.
```kotlin
package com.atherpulse.solasflow

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class AutoStartAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // No implementation needed. We just need the service enabled for permissions.
    }

    override fun onInterrupt() {}
}
```

**`android/app/src/main/res/xml/accessibility_service_config.xml`**
```xml
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/accessibility_service_description"
    android:accessibilityEventTypes="typeAllMask"
    android:accessibilityFlags="flagDefault"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:notificationTimeout="100"
    android:canRetrieveWindowContent="false" />
```

## Phase 2: Flutter Implementation

### 1. Method Channel Check
Create a `MethodChannel` in `MainActivity.kt` to check if the user has enabled the Accessibility Service.
```kotlin
// In MainActivity.kt
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.atherpulse.solasflow/permissions")
    .setMethodCallHandler { call, result ->
        if (call.method == "isAccessibilityEnabled") {
            result.success(checkAccessibilityEnabled())
        } else if (call.method == "openAccessibilitySettings") {
            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
            result.success(true)
        } else {
            result.notImplemented()
        }
    }
```

### 2. Provide UI to User
In SolasFlow, add a Settings toggle or prompt requiring the user to enable the service:
1. Explain to the user: *"To automatically restart your timer when your phone reboots, SolasFlow needs its Accessibility Service enabled."*
2. Tap button -> invokes `openAccessibilitySettings` via MethodChannel.
3. Once enabled, the platform is ready: upon reboot, the `BootReceiver` fires and `MainActivity` will be brought directly to the foreground.

## Considerations
*   **Play Store Policy**: Google Play strictly reviews Accessibility Services. Since you are not using it to read the screen (only to utilize background exemption policies for boot relaunching), clearly document in the Play Store Console *why* you are requesting it, though there's a risk of rejection if they determine a timer app isn't a valid "Accessibility" use case.
*   **Alternative**: The alternative (Android recommended) is simply starting a Foreground Service (via `flutter_foreground_task`) at boot. The service posts an ongoing Notification saying "SolasFlow available", but the user must tap the notification to bring the UI up instead of it popping up forcefully.