package com.example.speakertimer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget 1: Timer Presets Quick Start
 *
 * Displays the last known timer value and 10 preset buttons (5, 10, 15, 20, 25, 30, 45, 60, 90, 120 min).
 * Also has an "Open App" button.
 * State is read from FlutterSharedPreferences (written by Flutter on every settings save).
 */
class TimerPresetsWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateTimerPresetsWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_TIMER_VALUE = "flutter.widget_timer_display"

        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, TimerPresetsWidget::class.java)
            )
            for (id in ids) updateTimerPresetsWidget(context, mgr, id)
        }

        fun updateTimerPresetsWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val timerDisplay = prefs.getString(KEY_TIMER_VALUE, "00:00") ?: "00:00"

            val views = RemoteViews(context.packageName, R.layout.widget_timer_presets)
            views.setTextViewText(R.id.widget_timer_value, timerDisplay)

            // Open App button
            views.setOnClickPendingIntent(
                R.id.btn_open_app,
                makeActionIntent(context, "open_app", appWidgetId)
            )

            // Preset buttons
            val presets = listOf(
                R.id.btn_5m to "start_5m",
                R.id.btn_10m to "start_10m",
                R.id.btn_15m to "start_15m",
                R.id.btn_20m to "start_20m",
                R.id.btn_25m to "start_25m",
                R.id.btn_30m to "start_30m",
                R.id.btn_45m to "start_45m",
                R.id.btn_60m to "start_60m",
                R.id.btn_90m to "start_90m",
                R.id.btn_120m to "start_120m"
            )

            for ((viewId, action) in presets) {
                views.setOnClickPendingIntent(
                    viewId,
                    makeActionIntent(context, action, appWidgetId)
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun makeActionIntent(context: Context, action: String, widgetId: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                putExtra("widget_action", action)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context,
                // Use a unique request code per (action + widgetId) to avoid PendingIntent collisions
                (action.hashCode() and 0xFFFF) or (widgetId shl 16),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
