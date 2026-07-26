package com.atherpulse.solasflow

import android.app.PendingIntent
import com.atherpulse.solasflow.R
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget 1: Timer Presets Quick Start
 *
 * Minimal preset-button grid with "SolasFlow" branding title.
 * Tapping the title opens the app; tapping a button starts that timer preset.
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
            val views = RemoteViews(context.packageName, R.layout.widget_timer_presets)

            // Open App — tap on title to open app
            views.setOnClickPendingIntent(
                R.id.widget_title,
                makeActionIntent(context, "open_app", appWidgetId)
            )

            // Preset buttons — 3 rows × 5 columns
            val presets = listOf(
                R.id.btn_1m to "start_1m",
                R.id.btn_2m to "start_2m",
                R.id.btn_3m to "start_3m",
                R.id.btn_5m to "start_5m",
                R.id.btn_7m to "start_7m",
                R.id.btn_10m to "start_10m",
                R.id.btn_12m to "start_12m",
                R.id.btn_15m to "start_15m",
                R.id.btn_20m to "start_20m",
                R.id.btn_25m to "start_25m",
                R.id.btn_30m to "start_30m",
                R.id.btn_35m to "start_35m",
                R.id.btn_45m to "start_45m",
                R.id.btn_60m to "start_60m",
                R.id.btn_90m to "start_90m"
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
