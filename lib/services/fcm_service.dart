import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class FcmService {
  static const _projectId = 'expencetracker-9f731';

  /// Minimal listener for foreground messages (keeps previous behavior).
  static void firebaseInit() {
    // Keep simple logging for foreground messages
    // ignore: avoid_print
    FirebaseMessaging.onMessage.listen((message) {
      // ignore: avoid_print
      print('Foreground FCM message: ${message.notification?.title}');
    });
  }

  /// Send a PDF-export notification to this device using stored server access token
  /// and the device's FCM token stored in Hive ('token' box -> 'fcmToken').
  static Future<bool> sendPdfNotification({
    required String pdfPath,
    String title = 'PDF Exported',
    String body = 'Your PDF report is ready',
  }) async {
    try {
      // Device token
      if (!Hive.isBoxOpen('token')) await Hive.openBox<String>('token');
      final tokenBox = Hive.box<String>('token');
      final deviceToken = tokenBox.get('fcmToken');
      if (deviceToken == null || deviceToken.isEmpty) {
        // ignore: avoid_print
        print('No device FCM token found in Hive');
        return false;
      }

      // Server access token
      if (!Hive.isBoxOpen('serverKeyBox'))
        await Hive.openBox<String>('serverKeyBox');
      final serverBox = Hive.box<String>('serverKeyBox');
      final accessToken = serverBox.get('server_access_token');
      if (accessToken == null || accessToken.isEmpty) {
        // ignore: avoid_print
        print('No server access token found in Hive');
        return false;
      }

      final uri = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );
      final payload = {
        'message': {
          'token': deviceToken,
          'notification': {'title': title, 'body': body},
          'data': {'pdf_path': pdfPath},
        },
      };

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(payload),
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print('FCM send status=${resp.statusCode} body=${resp.body}');
      }

      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e, st) {
      // ignore: avoid_print
      print('Error sending PDF FCM notification: $e\n$st');
      return false;
    }
  }
}
