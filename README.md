# Military Communication App

This application is designed for military personnel doing their compulsory service who need to use push-button phones but want to stay connected through social media platforms.

## 📱 Application Purpose

Enables military personnel using push-button phones to:
- Forward SMS messages from their push-button phones to Telegram contacts
- Send incoming Telegram messages as SMS to their push-button phones
- Maintain two-way communication despite device limitations

## ✨ Features

- **SMS → Telegram Forwarding**: Automatically forwards SMS from push-button phones to Telegram
- **Telegram → SMS Forwarding**: Automatically sends incoming Telegram messages as SMS
- **Real-time Notifications**: Instant message delivery and status updates
- **Message History**: Keeps records of all sent and received messages
- **User-friendly Interface**: Simple setup and intuitive operation

## 🛠️ Installation

### Requirements

- Flutter SDK ^3.9.2
- Android phone (for SMS permissions)
- Telegram bot token (obtain from BotFather)
- Telegram chat ID

### Steps

1. Clone or download the project
2. Install required packages:
   ```bash
   flutter pub get
   ```

3. Configure Android permissions (AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.SEND_SMS" />
   <uses-permission android:name="android.permission.RECEIVE_SMS" />
   <uses-permission android:name="android.permission.READ_SMS" />
   <uses-permission android:name="android.permission.RECEIVE_MMS" />
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Telegram Bot Setup

1. Create a new bot with [BotFather](https://t.me/BotFather) on Telegram
2. Enter the received token in the "Bot Token" field
3. Send a message to your bot to identify your chat ID
4. Enter the chat ID in the "Chat ID" field
5. Click the "Connect Telegram" button

### SMS Settings

1. Enter the push-button phone number in the "Target Phone Number" field
2. Click the "Save Number" button

## 📋 How to Use

1. **Send SMS**: Type your message in the text field at the bottom and click "Send SMS"
2. **Send Telegram Message**: Type your message and click "Send Telegram"
3. **Automatic Forwarding**: Incoming SMS are automatically forwarded to Telegram, and incoming Telegram messages are automatically sent as SMS
4. **Message History**: All sent and received messages can be viewed in the "Message History" section

## 🏗️ Technical Details

### Technologies Used

- **Flutter**: Cross-platform mobile application framework
- **HTTP**: For communication with Telegram API
- **Provider**: For state management
- **Permission Handler**: For SMS permission management
- **Native Channels**: For Android SMS operations

### Architecture

- **MVVM Pattern**: Developed using Model-View-ViewModel architecture
- **Provider Pattern**: Provider used for state management
- **Native Communication**: Method channels used for platform-specific operations

### File Structure

```
lib/
├── main.dart
├── app.dart
├── native_channel.dart
├── screens/
│   └── home_screen.dart
└── services/
    ├── telegram_service.dart
    └── sms_service.dart
android/
└── app/
    └── src/
        └── main/
            └── kotlin/
                └── com/
                    └── example/
                        └── army_message_v1/
                            ├── MainActivity.kt
                            ├── SmsEventChannel.kt
                            ├── SmsReader.kt
                            └── SmsReceiver.kt
```

## 📄 License

This project was developed to address communication needs during military service. Designed for personal use.

## 🤝 Contributing

To contribute:
1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazingFeature`)
3. Commit your changes (`git commit -m 'Add some amazingFeature'`)
4. Push to the branch (`git push origin feature/amazingFeature`)
5. Open a Pull Request

## ❓ Frequently Asked Questions

**Q: My Telegram bot isn't receiving messages?**
A: You may need to disable privacy mode using the `/setprivacy` command with BotFather.

**Q: SMS sending isn't working?**
A: Ensure the app has SMS permissions and you've entered the correct phone number.

**Q: The app stops working in the background?**
A: Allow background operation in Android's battery optimization settings for this app.

---

**Note**: This application was developed to address communication needs during military service. It should be used in compliance with communication rules and regulations at military facilities.