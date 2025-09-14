package com.example.army_message_v1

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SmsManager

class MainActivity: FlutterActivity() {
    private val channel = "army_message_v1/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    try {
                        val number = call.argument<String>("number")
                        val message = call.argument<String>("message")
                        if (number != null && message != null) {
                            sendSms(number, message)
                            result.success("SMS sent successfully")
                        } else {
                            result.error("INVALID_ARGUMENTS", "Number or message is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("SMS_ERROR", "SMS gönderilemedi: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendSms(number: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(number, null, message, null, null)
        } catch (e: Exception) {
            throw e
        }
    }
}