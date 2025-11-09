import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'get_server_key.dart';

class SendNotificationService {
  final String _projectId = 'expencetracker-9f731';

  Future<String?> _resolveAccessToken() async {
    try {
      // Prefer stored token in Hive if available
      if (!Hive.isBoxOpen('serverKeyBox'))
        await Hive.openBox<String>('serverKeyBox');
      final box = Hive.box<String>('serverKeyBox');
      final stored = box.get('server_access_token');
      if (stored != null && stored.isNotEmpty) return stored;

      // Fallback: generate a fresh access token using service account (GetServerKey)
      final getter = GetServerKey();
      final token = await getter.getServerKey();
      // store it for short-term reuse
      await box.put('server_access_token', token);
      return token;
    } catch (e) {
      // ignore: avoid_print
      print('Error resolving access token: $e');
      return null;
    }
  }

  Future<bool> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _resolveAccessToken();
      if (accessToken == null) return false;

      final uri = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );
      final payload = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          if (data != null) 'data': data,
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

      // ignore: avoid_print
      print(
        'SendNotificationService status=${resp.statusCode} body=${resp.body}',
      );
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e, st) {
      // ignore: avoid_print
      print('Error sending notification: $e\n$st');
      return false;
    }
  }

  Future<bool> sendPdfNotificationToThisDevice(
    String pdfPath, {
    String title = 'PDF ready',
    String body = 'Your PDF has been exported',
  }) async {
    try {
      if (!Hive.isBoxOpen('token')) await Hive.openBox<String>('token');
      final tokenBox = Hive.box<String>('token');
      final deviceToken = tokenBox.get('fcmToken');
      if (deviceToken == null || deviceToken.isEmpty) return false;

      return await sendToToken(
        token: deviceToken,
        title: title,
        body: body,
        data: {'pdf_path': pdfPath},
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error sending PDF notification to this device: $e');
      return false;
    }
  }

  Future<bool> sendSimpleNotificationToThisDevice({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      if (!Hive.isBoxOpen('token')) await Hive.openBox<String>('token');
      final tokenBox = Hive.box<String>('token');
      final deviceToken = tokenBox.get('fcmToken');
      if (deviceToken == null || deviceToken.isEmpty) return false;

      return await sendToToken(
        token: deviceToken,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error sending simple notification to this device: $e');
      return false;
    }
  }
}
