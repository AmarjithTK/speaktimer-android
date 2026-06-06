package com.atherpulse.solasflow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget: Speech Controls
 *
 * Minimal widget with actionable buttons:
 * - Master Audio Toggle (global ON/OFF)
 * - Fullscreen Clock
 *
 * Two-tap confirmation is managed on the Flutter side via SharedPreferences
 * armed state. The widget reads the armed state and shows a distinct visual.
 */
class SpeechControlsWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SPEECH_MASTER = "flutter.widget_speech_master"
        private const val KEY_ARMED_ACTION = "widget_armed_action"

        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, SpeechControlsWidget::class.java)
            )
            for (id in ids) updateWidget(context, mgr, id)
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val speechMasterOn = prefs.getBoolean(KEY_SPEECH_MASTER, true)
            val armedAction = prefs.getString(KEY_ARMED_ACTION, "") ?: ""

            val audioArmed = armedAction == "audio_master"
            val clockArmed = armedAction == "fullscreen_clock"

            val views = RemoteViews(context.packageName, R.layout.widget_speech_controls)

            // ── Master Audio Button ──────────────────────────────────────
            views.setTextViewText(
                R.id.btn_audio_master,
                if (speechMasterOn) "Audio ON" else "Audio OFF"
            )
            views.setInt(
                R.id.btn_audio_master, "setBackgroundResource",
                when {
                    audioArmed -> R.drawable.widget_button_armed_bg
                    speechMasterOn -> R.drawable.widget_button_active_bg
                    else -> R.drawable.widget_button_bg
                }
            )
            views.setOnClickPendingIntent(
                R.id.btn_audio_master,
                makeIntent(context, "toggle_speech_master", appWidgetId, 1)
            )

            // ── Fullscreen Clock Button ──────────────────────────────────
            views.setTextViewText(R.id.btn_fs_clock, "Open Clock")
            views.setInt(
                R.id.btn_fs_clock, "setBackgroundResource",
                if (clockArmed) R.drawable.widget_button_armed_bg
                else R.drawable.widget_button_bg
            )
            views.setOnClickPendingIntent(
                R.id.btn_fs_clock,
                makeIntent(context, "open_fullscreen_clock", appWidgetId, 2)
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun makeIntent(
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
