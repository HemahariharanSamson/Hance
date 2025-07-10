package com.example.hfin

import android.Manifest
import android.content.ContentResolver
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestSmsPermissions" -> requestSmsPermissions(result)
                "getTodaySms" -> getTodaySms(result)
                "getHistoricalSms" -> getHistoricalSms(call, result)
                else -> result.notImplemented()
            }
        }
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

    private fun getTodaySms(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
            return
        }

        try {
            val todaySms = mutableListOf<Map<String, Any>>()
            val contentResolver: ContentResolver = contentResolver
            val uri = Uri.parse("content://sms/inbox")
            
            // Get today's date in milliseconds
            val calendar = Calendar.getInstance()
            calendar.set(Calendar.HOUR_OF_DAY, 0)
            calendar.set(Calendar.MINUTE, 0)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            val todayStart = calendar.timeInMillis
            
            val cursor: Cursor? = contentResolver.query(
                uri,
                arrayOf("_id", "address", "body", "date"),
                "date >= ?",
                arrayOf(todayStart.toString()),
                "date DESC"
            )

            cursor?.use { c ->
                while (c.moveToNext()) {
                    val address = c.getString(c.getColumnIndexOrThrow("address"))
                    val body = c.getString(c.getColumnIndexOrThrow("body"))
                    val date = c.getLong(c.getColumnIndexOrThrow("date"))
                    
                    todaySms.add(mapOf(
                        "sender" to (address ?: ""),
                        "body" to (body ?: ""),
                        "timestamp" to date
                    ))
                }
            }
            
            result.success(todaySms)
        } catch (e: Exception) {
            result.error("SMS_READ_ERROR", "Error reading SMS: ${e.message}", null)
        }
    }

    private fun getHistoricalSms(call: MethodCall, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
            return
        }

        try {
            val startTimestamp = call.argument<Long>("startTimestamp") ?: 0L
            val endTimestamp = call.argument<Long>("endTimestamp") ?: System.currentTimeMillis()
            
            val historicalSms = mutableListOf<Map<String, Any>>()
            val contentResolver: ContentResolver = contentResolver
            val uri = Uri.parse("content://sms/inbox")
            
            val cursor: Cursor? = contentResolver.query(
                uri,
                arrayOf("_id", "address", "body", "date"),
                "date >= ? AND date <= ?",
                arrayOf(startTimestamp.toString(), endTimestamp.toString()),
                "date DESC"
            )

            cursor?.use { c ->
                while (c.moveToNext()) {
                    val address = c.getString(c.getColumnIndexOrThrow("address"))
                    val body = c.getString(c.getColumnIndexOrThrow("body"))
                    val date = c.getLong(c.getColumnIndexOrThrow("date"))
                    
                    historicalSms.add(mapOf(
                        "sender" to (address ?: ""),
                        "body" to (body ?: ""),
                        "timestamp" to date
                    ))
                }
            }
            
            result.success(historicalSms)
        } catch (e: Exception) {
            result.error("SMS_READ_ERROR", "Error reading historical SMS: ${e.message}", null)
        }
    }
}
