package com.atherpulse.solasflow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON") {
            return
        }

        // Attempt to start the foreground service via the plugin's service class.
        // This ensures the persistent notification appears even if the Activity
        // cannot be launched (Android 12+ background restrictions).
        try {
            val serviceIntent = Intent(
                context,
                Class.forName("com.pravera.flutter_foreground_task.service.ForegroundService")
            )
            serviceIntent.action = "START_FOREGROUND_TASK"
            serviceIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startForegroundService(serviceIntent)
        } catch (e: Exception) {
            Log.w("BootReceiver", "Could not start foreground service: ${e.message}")
        }

        // Launch MainActivity to initialize app state (may be blocked on Android 12+
        // without accessibility service exemption; fails silently).
        runCatching {
            val launchIntent = Intent(context, MainActivity::class.java)
            launchIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            )
            context.startActivity(launchIntent)
        }.onFailure { e ->
            Log.w("BootReceiver", "Could not launch Activity (expected on 12+): ${e.message}")
            // Fall back: update widgets so they reflect last known state
            runCatching {
                SpeechControlsWidget.updateAllWidgets(context)
                TimerPresetsWidget.updateAllWidgets(context)
            }
        }
    }
}
