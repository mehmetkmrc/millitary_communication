import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/telegram_service.dart';
import '../services/sms_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _botTokenController = TextEditingController();
  final _chatIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final smsService = Provider.of<SmsService>(context, listen: false);
    await smsService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final telegramService = Provider.of<TelegramService>(context);
    final smsService = Provider.of<SmsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asker Mesajlaşma Sistemi'),
        backgroundColor: Colors.green[700],  
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              smsService.clearMessages();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Durum Göstergesi
              _buildStatusIndicator(telegramService, smsService),
              const SizedBox(height: 20),
              
              // Telegram Ayarları
              _buildTelegramSettings(telegramService),
              const SizedBox(height: 20),
              
              // SMS Ayarları
              _buildSmsSettings(smsService),
              const SizedBox(height: 20),
              
              // Mesaj Gönderme
              _buildMessageSender(smsService, telegramService),
              const SizedBox(height: 20),
              
              // Mesaj Listesi
              _buildMessagesList(smsService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(TelegramService telegramService, SmsService smsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              telegramService.isConnected ? Icons.check_circle : Icons.error,
              color: telegramService.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              telegramService.isConnected ? 'Telegram Bağlı' : 'Telegram Bağlı Değil',
              style: TextStyle(
                color: telegramService.isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.sms,
              color: smsService.targetPhoneNumber.isNotEmpty ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              smsService.targetPhoneNumber.isNotEmpty ? 'SMS Ayarlandı' : 'SMS Ayarı Yok',
              style: TextStyle(
                color: smsService.targetPhoneNumber.isNotEmpty ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelegramSettings(TelegramService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 Telegram Ayarları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _botTokenController,
              decoration: const InputDecoration(
                labelText: 'Bot Token',
                hintText: '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _chatIdController,
              decoration: const InputDecoration(
                labelText: 'Chat ID',
                hintText: '123456789',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (_botTokenController.text.isEmpty || _chatIdController.text.isEmpty) {
                  _showSnackbar('Lütfen tüm alanları doldurun');
                  return;
                }
                
                service.initializeBot(
                  _botTokenController.text,
                  _chatIdController.text,
                );
                _showSnackbar('Telegram bot bağlandı ✓');
              },
              icon: const Icon(Icons.telegram),
              label: const Text('Telegram Bağlan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsSettings(SmsService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📞 SMS Ayarları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Hedef Telefon Numarası',
                hintText: '+905551234567',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (_phoneNumberController.text.isEmpty) {
                  _showSnackbar('Lütfen telefon numarası girin');
                  return;
                }
                
                service.targetPhoneNumber = _phoneNumberController.text;
                _showSnackbar('Numara kaydedildi ✓');
              },
              icon: const Icon(Icons.save),
              label: const Text('Numarayı Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSender(SmsService smsService, TelegramService telegramService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✉️ Mesaj Gönder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Mesajınız',
                hintText: 'Merhaba, nasılsın?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_messageController.text.isEmpty) {
                        _showSnackbar('Lütfen mesaj yazın');
                        return;
                      }
                      if (smsService.targetPhoneNumber.isEmpty) {
                        _showSnackbar('Lütfen önce telefon numarası ayarlayın');
                        return;
                      }

                      try {
                        await smsService.sendSms(_messageController.text);
                        _showSnackbar('SMS gönderildi ✓');
                        _messageController.clear();
                      } catch (e) {
                        _showSnackbar('SMS gönderilemedi: $e');
                      }
                    },
                    icon: const Icon(Icons.sms),
                    label: const Text('SMS Gönder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_messageController.text.isEmpty) {
                        _showSnackbar('Lütfen mesaj yazın');
                        return;
                      }
                      if (!telegramService.isConnected) {
                        _showSnackbar('Lütfen önce Telegram bağlantısı kurun');
                        return;
                      }

                      try {
                        await telegramService.sendMessage(_messageController.text);
                        _showSnackbar('Telegram mesajı gönderildi ✓');
                        _messageController.clear();
                      } catch (e) {
                        _showSnackbar('Telegram gönderilemedi: $e');
                      }
                    },
                    icon: const Icon(Icons.telegram),
                    label: const Text('Telegram Gönder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(SmsService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '📨 Mesaj Geçmişi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '(${service.messages.length} mesaj)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            service.messages.isEmpty
                ? const Center(
                    child: Column(
                      children: [
                        Icon(Icons.sms, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Henüz mesaj yok'),
                        Text('Gelen mesajlar burada görünecek', 
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: service.messages.length,
                    itemBuilder: (context, index) {
                      final message = service.messages[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.grey[100],
                        child: ListTile(
                          leading: const Icon(Icons.message, color: Colors.green),
                          title: Text(
                            message.length > 50 ? '${message.substring(0, 50)}...' : message,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Mesaj ${index + 1}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              // Kopyalama işlevi eklenebilir
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    _phoneNumberController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}