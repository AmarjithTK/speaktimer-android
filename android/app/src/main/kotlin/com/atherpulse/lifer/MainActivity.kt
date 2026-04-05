package com.atherpulse.lifer

import android.content.Intent
import android.content.Context
import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val WIDGET_CHANNEL = "com.atherpulse.lifer/widget"
    private val AUDIO_CHANNEL = "com.atherpulse.lifer/audio"
    private var methodChannel: MethodChannel? = null
    private var audioChannel: MethodChannel? = null
    private var pendingWidgetAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "refreshWidgets") {
                // Flutter instructs native to refresh widget UI
                TimerPresetsWidget.updateAllWidgets(applicationContext)
                SpeechControlsWidget.updateAllWidgets(applicationContext)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        audioChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
        audioChannel?.setMethodCallHandler { call, result ->
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
                    val ratioArg = call.argument<Double>("ratio")
                    if (ratioArg == null) {
                        result.error("missing_ratio", "ratio is required", null)
                        return@setMethodCallHandler
                    }
                    val ratio = ratioArg.coerceIn(0.0, 1.0)
                    val target = (ratio * max.toDouble()).toInt().coerceIn(0, max)
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
                    result.success(null)
                }

                "setMediaVolumeToMax" -> {
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, max, 0)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleWidgetIntent(intent)
    }

    private fun handleWidgetIntent(intent: Intent?) {
        val action = intent?.getStringExtra("widget_action") ?: return
        // If Flutter engine is not ready yet, store action for later
        val mc = methodChannel
        if (mc != null) {
            mc.invokeMethod("widgetAction", action)
        } else {
            pendingWidgetAction = action
        }
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        // Deliver any action received before Flutter engine was ready
        val pending = pendingWidgetAction
        if (pending != null) {
            pendingWidgetAction = null
            methodChannel?.invokeMethod("widgetAction", pending)
        }
    }
}
