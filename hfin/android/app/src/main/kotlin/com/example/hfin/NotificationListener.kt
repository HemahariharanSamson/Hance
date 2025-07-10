package com.example.hfin

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.util.Log
import io.flutter.plugin.common.EventChannel

class NotificationListener : NotificationListenerService() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val extras: Bundle = sbn.notification.extras
        val title = extras.getString("android.title") ?: ""
        val text = extras.getString("android.text") ?: ""
        val packageName = sbn.packageName
        val timestamp = sbn.postTime

        Log.d("NotifDebug", "Notification from $packageName: $title - $text")

        // Filter for banking apps or relevant notifications
        if (isBankNotification(packageName, text)) {
            val data = mapOf(
                "title" to title,
                "text" to text,
                "package" to packageName,
                "timestamp" to timestamp
            )
            eventSink?.success(data)
        }
    }

    private fun isBankNotification(packageName: String, text: String): Boolean {
        // TODO: Add your logic to filter only bank notifications
        // For now, allow all notifications for testing
        return true
    }
} 