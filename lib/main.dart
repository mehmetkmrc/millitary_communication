import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/telegram_service.dart';
import 'services/sms_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TelegramService()),
        ChangeNotifierProvider(create: (context) => SmsService()),
      ],
      child: const MyApp(),
    ),
  );
}