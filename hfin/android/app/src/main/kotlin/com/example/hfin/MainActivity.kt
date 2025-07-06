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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity(), MethodCallHandler {
    private val CHANNEL = "sms_channel"
    private val EVENT_CHANNEL = "sms_events"
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var smsReceiver: BroadcastReceiver
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method channel for requesting permissions and saving transactions
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler(this)

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

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestSmsPermissions" -> {
                requestSmsPermissions(result)
            }
            "saveTransaction" -> {
                val transaction = call.arguments as Map<*, *>
                saveTransactionToStorage(transaction)
                result.success(true)
            }
            "getPendingTransactions" -> {
                val transactions = getPendingTransactions()
                result.success(transactions)
            }
            "clearPendingTransactions" -> {
                clearPendingTransactions()
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requestSmsPermissions(result: Result) {
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

    private fun saveTransactionToStorage(transaction: Map<*, *>) {
        // Save to SharedPreferences for now (simpler than Hive from native side)
        val prefs = getSharedPreferences("sms_transactions", Context.MODE_PRIVATE)
        val transactions = prefs.getStringSet("pending_transactions", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        
        // Convert transaction to JSON-like string for storage
        val transactionString = "${transaction["id"]}|${transaction["amount"]}|${transaction["merchant"]}|${transaction["timestamp"]}|${transaction["tag"]}"
        transactions.add(transactionString)
        
        prefs.edit().putStringSet("pending_transactions", transactions).apply()
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
                        
                        // Try to parse as transaction
                        val transaction = parseTransactionFromSms(body, sender, timestamp)
                        if (transaction != null) {
                            // Save to storage even if app is closed
                            saveTransactionToStorage(transaction)
                            
                            // Send to Flutter if app is open
                            eventSink?.success(transaction)
                        }
                    }
                }
            }
        }
        
        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        registerReceiver(smsReceiver, filter)
    }

    private fun parseTransactionFromSms(body: String, sender: String, timestamp: Long): Map<String, Any>? {
        // Simple regex for amount (₹ or Rs or INR), merchant (word after at/from)
        val amountRegex = Regex("""(?:₹|Rs\.?|INR)\s?(\d+[.,]?\d*)""")
        val merchantRegex = Regex("""(?:at|from)\s+([A-Za-z0-9 &]+)""")
        
        val amountMatch = amountRegex.find(body)
        val merchantMatch = merchantRegex.find(body)
        
        if (amountMatch != null) {
            val amount = amountMatch.groupValues[1].replace(",", "").toDoubleOrNull() ?: 0.0
            val merchant = merchantMatch?.groupValues?.get(1)?.trim() ?: sender
            
            return mapOf<String, Any>(
                "sender" to sender,
                "body" to body,
                "timestamp" to timestamp,
                "id" to System.currentTimeMillis().toInt(),
                "amount" to amount,
                "merchant" to merchant,
                "tag" to "null"
            )
        }
        return null
    }

    private fun unregisterSmsReceiver() {
        try {
            unregisterReceiver(smsReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }

    private fun getPendingTransactions(): List<Map<String, Any>> {
        val prefs = getSharedPreferences("sms_transactions", Context.MODE_PRIVATE)
        val transactionStrings = prefs.getStringSet("pending_transactions", mutableSetOf()) ?: mutableSetOf()
        
        val transactions = mutableListOf<Map<String, Any>>()
        for (transactionString in transactionStrings) {
            val parts = transactionString.split("|")
            if (parts.size >= 5) {
                val tag = if (parts[4] == "null") "null" else parts[4]
                val transaction = mapOf<String, Any>(
                    "id" to parts[0].toInt(),
                    "amount" to parts[1].toDouble(),
                    "merchant" to parts[2],
                    "timestamp" to parts[3].toLong(),
                    "tag" to tag
                )
                transactions.add(transaction)
            }
        }
        return transactions
    }

    private fun clearPendingTransactions() {
        val prefs = getSharedPreferences("sms_transactions", Context.MODE_PRIVATE)
        prefs.edit().remove("pending_transactions").apply()
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterSmsReceiver()
    }
}
