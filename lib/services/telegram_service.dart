import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TelegramService with ChangeNotifier {
  String? _botToken;
  String? _chatId;
  bool _isConnected = false;

  String? get botToken => _botToken;
  String? get chatId => _chatId;
  bool get isConnected => _isConnected;

  void initializeBot(String token, String chatId) {
    _botToken = token;
    _chatId = chatId;
    _isConnected = true;
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (_botToken == null || _chatId == null) {
      throw Exception('Telegram bot bağlantısı kurulmamış');
    }

    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot$_botToken/sendMessage',
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': _chatId,
          'text': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Telegram API hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Mesaj gönderilemedi: $e');
    }
  }
}