package com.example.hfin

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"
    private val EVENT_CHANNEL = "sms_events"
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var smsReceiver: BroadcastReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method channel for requesting permissions
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestSmsPermissions" -> {
                    requestSmsPermissions(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Event channel for SMS events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerSmsReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    unregisterSmsReceiver()
                }
            }
        )
    }

    private fun requestSmsPermissions(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val permissions = arrayOf(
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_SMS
            )
            
            val permissionsToRequest = mutableListOf<String>()
            for (permission in permissions) {
                if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                    permissionsToRequest.add(permission)
                }
            }
            
            if (permissionsToRequest.isEmpty()) {
                result.success(true)
            } else {
                ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), 100)
                result.success(true)
            }
        } else {
            result.success(true)
        }
    }

    private fun registerSmsReceiver() {
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                    val messages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                        Telephony.Sms.Intents.getMessagesFromIntent(intent)
                    } else {
                        @Suppress("DEPRECATION")
                        Telephony.Sms.Intents.getMessagesFromIntent(intent)
                    }
                    
                    messages?.forEach { sms ->
                        val sender = sms.originatingAddress ?: "Unknown"
                        val body = sms.messageBody ?: ""
                        val timestamp = sms.timestampMillis
                        
                        val smsData = mapOf(
                            "sender" to sender,
                            "body" to body,
                            "timestamp" to timestamp
                        )
                        
                        eventSink?.success(smsData)
                    }
                }
            }
        }
        
        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        registerReceiver(smsReceiver, filter)
    }

    private fun unregisterSmsReceiver() {
        try {
            unregisterReceiver(smsReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterSmsReceiver()
    }
}
