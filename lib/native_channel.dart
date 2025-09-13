import 'package:flutter/services.dart';

class NativeChannel {
  static const MethodChannel _channel = MethodChannel('army_message/sms');
  
  static void initializeSmsListener(Function(String) onSmsReceived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onSmsReceived") {
        onSmsReceived(call.arguments.toString());
      }
      return null;
    });
  }
}