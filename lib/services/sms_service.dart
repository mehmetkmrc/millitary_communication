import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService with ChangeNotifier {
  static const MethodChannel _methodChannel = MethodChannel('army_message_v1/sms');
  static const EventChannel _eventChannel = EventChannel('army_message_v1/sms_events');
  static const MethodChannel _channel = MethodChannel('army_message_v1/sms');
  final List<Map<String, String>> _messages = [];
  String _targetPhoneNumber = '';

  List<Map<String, String>> get messages => _messages;
  String get targetPhoneNumber => _targetPhoneNumber;

  // Yeni: Otomatik forward callback'i
  Function(String, String)? onSmsReceivedCallback;

  set targetPhoneNumber(String value) {
    _targetPhoneNumber = value;
    notifyListeners();
  }

  SmsService() {
    _initializeSmsListener();
  }

  void _initializeSmsListener() {

    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      final Map<dynamic, dynamic> data = event;
      final sender = data['sender']?.toString() ?? 'Bilinmeyen';
      final message = data['message']?.toString() ?? '';
      
      addMessage(sender, message, type: 'received');
      
      if (onSmsReceivedCallback != null) {
        onSmsReceivedCallback!(sender, message);
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('SMS event error: $error');
      }
    });



    _channel.setMethodCallHandler((call) async {
      if (call.method == "onSmsReceived") {
        try {
          final Map<dynamic, dynamic>? data = call.arguments;
          if (data != null) {
            final sender = data['sender']?.toString() ?? 'Bilinmeyen';
            final message = data['message']?.toString() ?? '';
            
            // Mesajı listeye ekle
            addMessage(sender, message, type: 'received');
            
            // Otomatik forward callback'ini çağır
            if (onSmsReceivedCallback != null) {
              onSmsReceivedCallback!(sender, message);
            }
            
            return {'status': 'received', 'sender': sender};
          }
        } catch (e) {
          if (kDebugMode) {
            print('SMS işleme hatası: $e');
          }
        }
      }
      return null;
    });
  }

  Future<bool> requestPermissions() async {
    // SMS izinlerini iste
    var smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      smsStatus = await Permission.sms.request();
    }
    
    return smsStatus.isGranted;
  }

  Future<void> checkForNewSms() async {
  try {
    await _channel.invokeMethod('checkNewSms');
  } catch (e) {
    throw Exception('SMS kontrol hatası: $e');
  }
 }


  Future<void> sendSms(String message) async {
    if (_targetPhoneNumber.isEmpty) {
      throw Exception('Hedef telefon numarası ayarlanmamış');
    }

    try {
      await _channel.invokeMethod('sendSms', {
        'number': _targetPhoneNumber,
        'message': message,
      });
      
      addMessage('Ben', message, type: 'sent');
    } catch (e) {
      throw Exception('SMS gönderilemedi: $e');
    }
  }

  void addMessage(String sender, String message, {String type = 'received'}) {
    _messages.add({
      'sender': sender,
      'message': message,
      'type': type,
      'time': DateTime.now().toString(),
    });
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}