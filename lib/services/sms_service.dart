import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService with ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('army_message_v1/sms');
  List<String> _messages = [];
  String _targetPhoneNumber = '';

  List<String> get messages => _messages;
  String get targetPhoneNumber => _targetPhoneNumber;

  set targetPhoneNumber(String value) {
    _targetPhoneNumber = value;
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  Future<void> sendSms(String message) async {
    if (_targetPhoneNumber.isEmpty) {
      throw Exception('Hedef telefon numarası ayarlanmamış');
    }

    try {
      // Kotlin tarafındaki sendSms metodunu çağır
      await _channel.invokeMethod('sendSms', {
        'number': _targetPhoneNumber,
        'message': message,
      });
      
      _messages.add('Gönderilen: $message');
      notifyListeners();
    } catch (e) {
      throw Exception('SMS gönderilemedi: $e');
    }
  }

  void addMessage(String message) {
    _messages.add('Alınan: $message');
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}