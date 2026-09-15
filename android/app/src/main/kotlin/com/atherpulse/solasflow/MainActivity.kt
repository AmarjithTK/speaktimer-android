package com.atherpulse.solasflow

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

class MainActivity : FlutterActivity() {
    private companion object {
        const val WIDGET_CHANNEL = "com.atherpulse.solasflow/widget"
        const val AUDIO_CHANNEL = "com.atherpulse.solasflow/audio"
        const val FLUTTER_PREFS = "FlutterSharedPreferences"
        const val ACTION_QUEUE_KEY = "native_widget_action_queue_v1"
    }

    private var widgetChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
        widgetChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetState" -> {
                    val state = call.arguments as? Map<*, *>
                    if (state == null) {
                        result.error("invalid_state", "Widget state map is required", null)
                    } else {
                        updateWidgetState(state)
                        result.success(true)
                    }
                }
                "drainWidgetActions" -> result.success(readQueuedActions())
                "ackWidgetAction" -> {
                    val id = call.argument<String>("id")
                    if (id == null) {
                        result.error("missing_id", "Widget action id is required", null)
                    } else {
                        acknowledgeAction(id)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    if (max <= 0) {
                        result.error("audio_max_zero", "Media max volume unavailable", null)
                        return@setMethodCallHandler
                    }
                    when (call.method) {
                        "getMediaVolumeRatio" -> {
                            val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            result.success(current.toDouble() / max.toDouble())
                        }
                        "setMediaVolumeRatio" -> {
                            val ratio = call.argument<Double>("ratio")?.coerceIn(0.0, 1.0)
                            if (ratio == null) {
                                result.error("missing_ratio", "ratio is required", null)
                            } else {
                                val target = (ratio * max).toInt().coerceIn(0, max)
                                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
                                result.success(true)
                            }
                        }
                        "setMediaVolumeToMax" -> {
                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, max, 0)
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: SecurityException) {
                    result.error("audio_permission_denied", error.message, null)
                } catch (error: Exception) {
                    result.error("audio_failed", error.message, null)
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureWidgetIntent(intent)
    }

    private fun captureWidgetIntent(intent: Intent?) {
        val action = intent?.getStringExtra("widget_action") ?: return
        intent.removeExtra("widget_action")
        enqueueAction(action)
        widgetChannel?.invokeMethod("widgetActionsAvailable", null)
    }

    @Synchronized
    private fun enqueueAction(action: String) {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val queue = parseQueue(prefs.getString(ACTION_QUEUE_KEY, null))
        queue.put(
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("action", action)
        )
        prefs.edit().putString(ACTION_QUEUE_KEY, queue.toString()).commit()
    }

    @Synchronized
    private fun readQueuedActions(): List<Map<String, String>> {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val queue = parseQueue(prefs.getString(ACTION_QUEUE_KEY, null))
        return (0 until queue.length()).mapNotNull { index ->
            val item = queue.optJSONObject(index) ?: return@mapNotNull null
            val id = item.optString("id")
            val action = item.optString("action")
            if (id.isEmpty() || action.isEmpty()) null
            else mapOf("id" to id, "action" to action)
        }
    }

    @Synchronized
    private fun acknowledgeAction(id: String) {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val queue = parseQueue(prefs.getString(ACTION_QUEUE_KEY, null))
        val remaining = JSONArray()
        for (index in 0 until queue.length()) {
            val item = queue.optJSONObject(index) ?: continue
            if (item.optString("id") != id) remaining.put(item)
        }
        prefs.edit().putString(ACTION_QUEUE_KEY, remaining.toString()).commit()
    }

    private fun parseQueue(raw: String?): JSONArray = try {
        if (raw.isNullOrBlank()) JSONArray() else JSONArray(raw)
    } catch (_: Exception) {
        JSONArray()
    }

    private fun updateWidgetState(state: Map<*, *>) {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("flutter.widget_clock_on", state["clockOn"] as? Boolean ?: false)
            .putBoolean("flutter.widget_timer_speak", state["timerSpeakOn"] as? Boolean ?: true)
            .putBoolean("flutter.widget_stopwatch_speak", state["stopwatchSpeakOn"] as? Boolean ?: true)
            .putBoolean("flutter.widget_goals_on", state["goalReminderOn"] as? Boolean ?: false)
            .putBoolean("flutter.widget_speech_master", state["speechMasterOn"] as? Boolean ?: true)
            .putString("flutter.widget_timer_display", state["timerDisplay"]?.toString() ?: "00:00")
            .putString("flutter.widget_armed_action", state["armedAction"]?.toString() ?: "")
            .commit()
        TimerPresetsWidget.updateAllWidgets(applicationContext)
        SpeechControlsWidget.updateAllWidgets(applicationContext)
    }
}
