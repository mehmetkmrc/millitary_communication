import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TelegramService with ChangeNotifier {
  String? _botToken;
  String? _chatId;
  bool _isConnected = false;
  Timer? _pollingTimer;

  // Yeni: Telegram'dan gelen mesajları işlemek için callback
  Function(String, String)? onTelegramMessageReceived;

  String? get botToken => _botToken;
  String? get chatId => _chatId;
  bool get isConnected => _isConnected;

  void initializeBot(String token, String chatId) {
    _botToken = token;
    _chatId = chatId;
    _isConnected = true;
    _startPolling();
    notifyListeners();
  }


  // Yeni: Telegram mesajlarını kontrol etmek için polling mekanizması
  void _startPolling() {
    // Önceki timer'ı temizle
    _pollingTimer?.cancel();
    
    // Her 10 saniyede bir mesajları kontrol et
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isConnected) {
        _getUpdates();
      }
    });
  }


    // Yeni: Telegram'dan güncel mesajları al
  Future<void> _getUpdates() async {
    if (_botToken == null) return;

    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/getUpdates');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updates = data['result'] as List<dynamic>;
        
        for (var update in updates) {
          final message = update['message'] ?? update['edited_message'];
          if (message != null) {
            final text = message['text']?.toString() ?? '';
            final chatId = message['chat']['id']?.toString() ?? '';
            
            // Sadece hedef chat'ten gelen mesajları işle
            if (text.isNotEmpty && chatId == _chatId && onTelegramMessageReceived != null) {
              onTelegramMessageReceived!(chatId, text);
              
              // Bu mesajı işlendi olarak işaretlemek için offset güncelle
              final updateId = update['update_id'];
              await _markAsProcessed(updateId);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Telegram update hatası: $e');
      }
    }
  }

  // Yeni: İşlenen mesajları işaretle
  Future<void> _markAsProcessed(int updateId) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/getUpdates?offset=${updateId + 1}');
      await http.get(url);
    } catch (e) {
      if (kDebugMode) {
        print('Update işaretleme hatası: $e');
      }
    }
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

  // Yeni: Timer'ı temizle
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}