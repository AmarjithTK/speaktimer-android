package com.atherpulse.lifer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget 2: Speech Controls
 *
 * Shows 4 toggle buttons (Clock Speech, Timer Speech, Stopwatch Speech, Goals Speech)
 * and an Open App button. Toggle state is read from FlutterSharedPreferences.
 * Tapping a toggle launches MainActivity with widget_action = "toggle_xxx_speech".
 */
class SpeechControlsWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateSpeechControlsWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_CLOCK_ON = "flutter.widget_clock_on"
        private const val KEY_TIMER_SPEAK = "flutter.widget_timer_speak"
        private const val KEY_STOPWATCH_SPEAK = "flutter.widget_stopwatch_speak"
        private const val KEY_GOALS_ON = "flutter.widget_goals_on"

        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, SpeechControlsWidget::class.java)
            )
            for (id in ids) updateSpeechControlsWidget(context, mgr, id)
        }

        fun updateSpeechControlsWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val clockOn = prefs.getBoolean(KEY_CLOCK_ON, false)
            val timerSpeak = prefs.getBoolean(KEY_TIMER_SPEAK, true)
            val stopwatchSpeak = prefs.getBoolean(KEY_STOPWATCH_SPEAK, true)
            val goalsOn = prefs.getBoolean(KEY_GOALS_ON, false)

            val views = RemoteViews(context.packageName, R.layout.widget_speech_controls)

            // Set button labels reflecting current state
            views.setTextViewText(
                R.id.btn_clock_speech,
                "🕐 Clock: ${if (clockOn) "ON" else "OFF"}"
            )
            views.setTextViewText(
                R.id.btn_timer_speech,
                "⏱ Timer: ${if (timerSpeak) "ON" else "OFF"}"
            )
            views.setTextViewText(
                R.id.btn_stopwatch_speech,
                "⏹ Stopwatch: ${if (stopwatchSpeak) "ON" else "OFF"}"
            )
            views.setTextViewText(
                R.id.btn_goals_speech,
                "🎯 Goals: ${if (goalsOn) "ON" else "OFF"}"
            )
            views.setTextViewText(R.id.btn_fs_clock, "🖥 Clock FS")
            views.setTextViewText(R.id.btn_fs_timer, "🚀 Timer FS")
            views.setTextViewText(R.id.btn_fs_stopwatch, "⚡ SW FS")

            // Set backgrounds reflecting state
            views.setInt(
                R.id.btn_clock_speech, "setBackgroundResource",
                if (clockOn) R.drawable.widget_button_active_bg else R.drawable.widget_button_bg
            )
            views.setInt(
                R.id.btn_timer_speech, "setBackgroundResource",
                if (timerSpeak) R.drawable.widget_button_active_bg else R.drawable.widget_button_bg
            )
            views.setInt(
                R.id.btn_stopwatch_speech, "setBackgroundResource",
                if (stopwatchSpeak) R.drawable.widget_button_active_bg else R.drawable.widget_button_bg
            )
            views.setInt(
                R.id.btn_goals_speech, "setBackgroundResource",
                if (goalsOn) R.drawable.widget_button_active_bg else R.drawable.widget_button_bg
            )

            // Click listeners
            views.setOnClickPendingIntent(
                R.id.btn_open_app,
                makeActionIntent(context, "open_app", appWidgetId, 0)
            )
            views.setOnClickPendingIntent(
                R.id.btn_clock_speech,
                makeActionIntent(context, "toggle_clock_speech", appWidgetId, 1)
            )
            views.setOnClickPendingIntent(
                R.id.btn_timer_speech,
                makeActionIntent(context, "toggle_timer_speech", appWidgetId, 2)
            )
            views.setOnClickPendingIntent(
                R.id.btn_stopwatch_speech,
                makeActionIntent(context, "toggle_stopwatch_speech", appWidgetId, 3)
            )
            views.setOnClickPendingIntent(
                R.id.btn_goals_speech,
                makeActionIntent(context, "toggle_goals_speech", appWidgetId, 4)
            )
            views.setOnClickPendingIntent(
                R.id.btn_fs_clock,
                makeActionIntent(context, "open_fullscreen_clock", appWidgetId, 5)
            )
            views.setOnClickPendingIntent(
                R.id.btn_fs_timer,
                makeActionIntent(context, "start_timer_fullscreen", appWidgetId, 6)
            )
            views.setOnClickPendingIntent(
                R.id.btn_fs_stopwatch,
                makeActionIntent(context, "start_stopwatch_fullscreen", appWidgetId, 7)
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun makeActionIntent(
            context: Context,
            action: String,
            widgetId: Int,
            slot: Int
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                putExtra("widget_action", action)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context,
                widgetId * 10 + slot,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
