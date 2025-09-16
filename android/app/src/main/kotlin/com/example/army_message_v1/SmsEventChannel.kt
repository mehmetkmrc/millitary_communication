package com.example.army_message_v1

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel

object SmsEventChannel {
    private const val CHANNEL_NAME = "army_message_v1/sms_events"
    private var eventSink: EventChannel.EventSink? = null

    fun initialize(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    fun sendSmsToFlutter(context: Context, sender: String, message: String) {
        try {
            eventSink?.success(mapOf(
                "sender" to sender,
                "message" to message
            ))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}