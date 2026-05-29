package com.atherpulse.solasflow

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/**
 * Placeholder AccessibilityService that grants the app system-level exemptions
 * for background activity launches. No accessibility functionality is used.
 * Having this service enabled by the user allows BootReceiver to launch
 * MainActivity immediately after device restart.
 */
class AutoStartAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // No implementation needed. The service is a permission enabler only.
    }

    override fun onInterrupt() {}
}
