import 'package:flutter/services.dart';

class SmsUserConsentService {
  static const MethodChannel _channel =
  MethodChannel('sms_user_consent');

  static Future<String?> startListening() async {
    try {
      final String? message =
      await _channel.invokeMethod<String>(
        'startSmsUserConsent',
      );

      return message;
    } on PlatformException catch (e) {
      print('SMS Error: ${e.message}');
      return null;
    }
  }
}