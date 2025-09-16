package com.example.army_message_v1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle: Bundle? = intent.extras
            if (bundle != null) {
                val pdus = bundle.get("pdus") as Array<*>?
                if (pdus != null) {
                    for (pdu in pdus) {
                        val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                        val sender = smsMessage.originatingAddress ?: "Bilinmeyen"
                        val messageBody = smsMessage.messageBody ?: ""
                        
                        // Flutter'a event channel ile gönder
                        SmsEventChannel.sendSmsToFlutter(context, sender, messageBody)
                    }
                }
            }
        }
    }
}