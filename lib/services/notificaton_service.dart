import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_settings/app_settings.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class NotificatonService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterlocalnotificationsplugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase notifications
  Future<void> initNotification() async {
    try {
      // Request permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        _showSnackbar(
          title: "Permission Denied",
          message:
              "Notification permission was denied. Please enable it in settings.",
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        Future.delayed(const Duration(seconds: 2), () {
          AppSettings.openAppSettings(type: AppSettingsType.notification);
        });
      }

      // Get FCM token
      String? token = await messaging.getToken();
      // ignore: avoid_print
      print("Firebase Messaging Token: $token");
      try {
        if (!Hive.isBoxOpen('token')) {
          await Hive.openBox<String>('token');
        }
        final box = Hive.box<String>('token');
        if (token != null) {
          await box.put('fcmToken', token);
        }
      } catch (e, st) {
        // ignore: avoid_print
        print('Failed to store FCM token in Hive: $e\n$st');
      }

      // Initialize local notifications
      await initLocalNotification();

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        firebaseNotificationHandeler(message);
      });

      // Listen for background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Background message tapped: ${message.notification?.title}');
        firebaseNotificationHandeler(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e, st) {
      print('Error initializing notifications: $e\n$st');
    }
  }

  /// Fetch recent notifications from Firestore
  Future<List<Map<String, dynamic>>> fetchNotifications({
    int limit = 50,
  }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final results = snap.docs
          .map(
            (d) => <String, dynamic>{
              'id': d.id,
              ...d.data() as Map<String, dynamic>,
            },
          )
          .toList();

      try {
        final box = await Hive.openBox<List>('notifications');
        await box.put('latest_notifications', results);
      } catch (e, st) {
        print('Failed to store notifications in Hive: $e\n$st');
      }

      return results;
    } catch (e, st) {
      print('Error fetching notifications from Firestore: $e\n$st');
      return <Map<String, dynamic>>[];
    }
  }

  /// Listen to realtime notifications
  void listenToNotifications() {
    try {
      FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
            for (final change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>?;
                if (data != null) {
                  _showSnackbar(
                    title: data['title']?.toString() ?? 'Notification',
                    message: data['body']?.toString() ?? '',
                    backgroundColor: Colors.teal,
                  );
                }
              }
            }
          });
    } catch (e, st) {
      print('Error listening to notifications: $e\n$st');
    }
  }

  /// Safe snackbar using GetX
  void _showSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Widget? icon,
    TextButton? mainButton,
  }) {
    try {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor ?? Colors.black87,
          colorText: Colors.white,
          icon: icon,
          mainButton: mainButton,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('$title: $message');
      }
    } catch (e, st) {
      print('Error showing snackbar: $e\n$st');
    }
  }

  /// Initialize local notifications
  Future<void> initLocalNotification() async {
    const AndroidInitializationSettings androidInitSetting =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings iosInitSetting =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSetting = InitializationSettings(
      android: androidInitSetting,
      iOS: iosInitSetting,
    );

    await _flutterlocalnotificationsplugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        // If we have a PDF path as payload, try to open it
        if (payload != null && payload.endsWith('.pdf')) {
          try {
            if (File(payload).existsSync()) {
              OpenFilex.open(payload);
            } else {
              // ignore: avoid_print
              print('PDF file not found at payload path: $payload');
            }
          } catch (e, st) {
            // ignore: avoid_print
            print('Error opening PDF from notification payload: $e\n$st');
          }
        } else {
          // ignore: avoid_print
          print('Notification tapped: ${response.payload}');
        }
      },
    );
  }

  /// Firebase notification handler
  Future<void> firebaseNotificationHandeler(RemoteMessage message) async {
    if (message.notification == null) return;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "channelId",
          "channelName",
          channelDescription:
              "This channel is used for important notifications.",
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    final pdfPath = message.data['pdf_path']?.toString();
    await _flutterlocalnotificationsplugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: pdfPath ?? message.data.toString(),
    );
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}
