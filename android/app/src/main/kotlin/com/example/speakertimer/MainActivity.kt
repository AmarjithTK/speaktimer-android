package com.example.speakertimer

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.speakertimer/widget"
    private var methodChannel: MethodChannel? = null
    private var pendingWidgetAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
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
