import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService with ChangeNotifier {
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

  // SMS gönderme method channel üzerinden
  Future<void> sendSms(String message) async {
    if (_targetPhoneNumber.isEmpty) {
      throw Exception('Hedef telefon numarası ayarlanmamış');
    }

    // Method channel çağrısı - MainActivity.kt'de handle ediliyor
    // Bu kısımda sadece state management yapıyoruz
    // Gerçek SMS gönderme native tarafta olacak
    _messages.add('Gönderilen: $message');
    notifyListeners();
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