package com.example.hfin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d(TAG, "SmsReceiver onReceive called with action: ${intent?.action}")
        
        when (intent?.action) {
            Telephony.Sms.Intents.SMS_RECEIVED_ACTION -> {
                Log.d(TAG, "SMS received, processing...")
                handleSmsReceived(context, intent)
            }
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.d(TAG, "Boot completed, receiver is active")
            }
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d(TAG, "Package replaced, receiver is active")
            }
        }
    }

    private fun handleSmsReceived(context: Context?, intent: Intent?) {
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
            
            Log.d(TAG, "SMS from: $sender, body: $body")
            
            // Try to parse as transaction
            val transaction = parseTransactionFromSms(body, sender, timestamp)
            if (transaction != null) {
                Log.d(TAG, "Transaction parsed successfully: $transaction")
                // Save to storage even when app is closed
                saveTransactionToStorage(context, transaction)
            } else {
                Log.d(TAG, "SMS did not match transaction pattern")
            }
        }
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

    private fun saveTransactionToStorage(context: Context?, transaction: Map<String, Any>) {
        context?.let {
            try {
                val prefs = it.getSharedPreferences("sms_transactions", Context.MODE_PRIVATE)
                val transactions = prefs.getStringSet("pending_transactions", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
                
                // Convert transaction to JSON-like string for storage
                val transactionString = "${transaction["id"]}|${transaction["amount"]}|${transaction["merchant"]}|${transaction["timestamp"]}|${transaction["tag"]}"
                transactions.add(transactionString)
                
                prefs.edit().putStringSet("pending_transactions", transactions).apply()
                Log.d(TAG, "Transaction saved to storage: $transactionString")
            } catch (e: Exception) {
                Log.e(TAG, "Error saving transaction to storage", e)
            }
        }
    }
} 