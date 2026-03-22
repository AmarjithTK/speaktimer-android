package com.example.speakertimer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class SpeechToggleWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_TOGGLE_SPEECH -> {
                toggleSpeechState(context)
            }
            ACTION_TIMER_TOGGLE -> {
                writeWidgetCommand(context, CMD_TIMER_TOGGLE)
            }
            ACTION_START_25M -> {
                writeWidgetCommand(context, CMD_START_25M)
            }
            ACTION_RESUME_LAST -> {
                writeWidgetCommand(context, CMD_RESUME_LAST)
            }
        }

        if (
            intent.action == ACTION_TOGGLE_SPEECH ||
            intent.action == ACTION_TIMER_TOGGLE ||
            intent.action == ACTION_START_25M ||
            intent.action == ACTION_RESUME_LAST
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, SpeechToggleWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            appWidgetIds.forEach { appWidgetId ->
                updateWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    private fun writeWidgetCommand(context: Context, command: String) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        prefs.edit().putString(WIDGET_COMMAND_KEY, command).apply()
    }

    private fun toggleSpeechState(context: Context) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val current = prefs.getBoolean(TIMER_SPEAK_KEY, true)
        val next = !current
        prefs.edit()
            .putBoolean(TIMER_SPEAK_KEY, next)
            .putBoolean(WIDGET_SPEECH_ON_KEY, next)
            .remove(WIDGET_COMMAND_KEY)
            .apply()
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val speechOn = if (prefs.contains(WIDGET_SPEECH_ON_KEY)) {
            prefs.getBoolean(WIDGET_SPEECH_ON_KEY, true)
        } else {
            prefs.getBoolean(TIMER_SPEAK_KEY, true)
        }
        val timerRunning = prefs.getBoolean(WIDGET_TIMER_RUNNING_KEY, false)
        val timerValue = prefs.getString(WIDGET_TIMER_VALUE_KEY, "00:00") ?: "00:00"
        val nightStatus = prefs.getString(WIDGET_NIGHT_STATUS_KEY, "Off") ?: "Off"
        val statusText = if (speechOn) "Speech: ON" else "Speech: OFF"
        val timerText = if (timerRunning) "Timer: Running ($timerValue)" else "Timer: Stopped"

        val views = RemoteViews(context.packageName, R.layout.speech_toggle_widget)
        views.setTextViewText(R.id.speech_widget_status, statusText)
        views.setTextViewText(R.id.speech_widget_timer, timerText)
        views.setTextViewText(R.id.speech_widget_night, "Night: $nightStatus")

        val toggleIntent = Intent(context, SpeechToggleWidgetProvider::class.java).apply {
            action = ACTION_TOGGLE_SPEECH
        }
        val togglePendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId,
            toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.speech_widget_toggle, togglePendingIntent)

        val timerToggleIntent = Intent(context, SpeechToggleWidgetProvider::class.java).apply {
            action = ACTION_TIMER_TOGGLE
        }
        val timerTogglePendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId + 2000,
            timerToggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.speech_widget_timer_toggle, timerTogglePendingIntent)

        val start25Intent = Intent(context, SpeechToggleWidgetProvider::class.java).apply {
            action = ACTION_START_25M
        }
        val start25PendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId + 3000,
            start25Intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.speech_widget_25m, start25PendingIntent)

        val resumeIntent = Intent(context, SpeechToggleWidgetProvider::class.java).apply {
            action = ACTION_RESUME_LAST
        }
        val resumePendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId + 4000,
            resumeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.speech_widget_resume, resumePendingIntent)

        val launchIntent = Intent(context, MainActivity::class.java)
        val launchPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId + 1000,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.speech_widget_open_app, launchPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    companion object {
        private const val ACTION_TOGGLE_SPEECH = "com.example.speakertimer.ACTION_TOGGLE_SPEECH"
        private const val ACTION_TIMER_TOGGLE = "com.example.speakertimer.ACTION_TIMER_TOGGLE"
        private const val ACTION_START_25M = "com.example.speakertimer.ACTION_START_25M"
        private const val ACTION_RESUME_LAST = "com.example.speakertimer.ACTION_RESUME_LAST"
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val TIMER_SPEAK_KEY = "flutter.TimerSpeakOn"
        private const val WIDGET_COMMAND_KEY = "flutter.WidgetCommand"
        private const val WIDGET_SPEECH_ON_KEY = "flutter.WidgetSpeechOn"
        private const val WIDGET_TIMER_RUNNING_KEY = "flutter.WidgetTimerRunning"
        private const val WIDGET_TIMER_VALUE_KEY = "flutter.WidgetTimerValue"
        private const val WIDGET_NIGHT_STATUS_KEY = "flutter.WidgetNightStatus"

        private const val CMD_TIMER_TOGGLE = "timer_toggle"
        private const val CMD_START_25M = "start_25m"
        private const val CMD_RESUME_LAST = "resume_last"
    }
}
