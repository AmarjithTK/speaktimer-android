package com.example.speakertimer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"speaktimer/widget",
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"refreshWidget" -> {
					SpeechToggleWidgetProvider.refreshAllWidgets(this)
					result.success(true)
				}
				else -> result.notImplemented()
			}
		}
	}
}
