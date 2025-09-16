package com.example.army_message_v1

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.Telephony
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class SmsReader(private val context: Context) {

    private val channel = "army_message_v1/sms"

    fun readAndSendNewSms() {
        try {
            val contentResolver: ContentResolver = context.contentResolver
            val cursor: Cursor? = contentResolver.query(
                Telephony.Sms.Inbox.CONTENT_URI,
                null,
                null,
                null,
                "${Telephony.Sms.Inbox.DATE} DESC" // En yeni mesajlar üstte
            )

            cursor?.use {
                val idIndex = it.getColumnIndex(Telephony.Sms._ID)
                val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
                val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
                val readIndex = it.getColumnIndex(Telephony.Sms.READ)

                // Sadece son 10 mesajı kontrol et
                var count = 0
                while (it.moveToNext() && count < 10) {
                    val id = it.getLong(idIndex)
                    val address = it.getString(addressIndex)
                    val body = it.getString(bodyIndex)
                    val isRead = it.getInt(readIndex) == 1

                    // Sadece okunmamış mesajları işle
                    if (!isRead && body != null && address != null) {
                        sendSmsToFlutter(address, body)
                        markAsRead(id)
                    }
                    
                    count++
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun sendSmsToFlutter(sender: String, message: String) {
        try {
            val flutterEngine = FlutterEngine(context)
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
                .invokeMethod("onSmsReceived", mapOf(
                    "sender" to sender,
                    "message" to message
                ))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun markAsRead(messageId: Long) {
        try {
            val values = android.content.ContentValues().apply {
                put(Telephony.Sms.READ, 1)
            }
            context.contentResolver.update(
                Uri.parse("content://sms/$messageId"),
                values,
                null,
                null
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}