import 'package:expence_track_hive/services/fcm_service.dart';
import 'package:expence_track_hive/services/get_server_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/expense.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';
import 'services/notificaton_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase is already initialized or initialization fails, log the error.
    // On Android/iOS the native config files (google-services.json / GoogleService-Info.plist)
    // are used. For web, provide FirebaseOptions when using the FlutterFire CLI.
    // We'll continue so Hive and the app can still start if Firebase isn't critical.
    // ignore: avoid_print
    print('Firebase initialization error: $e');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expensesBox');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //notificatonService notificatonService = notificatonService();
  NotificatonService notificatonService = NotificatonService();

  @override
  void initState() {
    super.initState();
    // Initialize notification service
    notificatonService.initNotification();
    notificatonService.messaging.getToken();
    // Fetch server key on app start (non-blocking)
    _fetchServerKey();
    FcmService.firebaseInit();
  }

  Future<void> _fetchServerKey() async {
    try {
      final getter = GetServerKey();
      final key = await getter.getServerKey();
      // ignore: avoid_print
      print('Fetched server key (access token): $key');
      // Store the server key in a Hive box. Note: storing service-account tokens or
      // private keys in a client app is insecure. Prefer server-side storage.
      try {
        final box = await Hive.openBox<String>('serverKeyBox');
        await box.put('server_access_token', key);
        // ignore: avoid_print
        print(
          'Server key stored in Hive box "serverKeyBox" under "server_access_token"',
        );
      } catch (e, st) {
        // ignore: avoid_print
        print('Failed to store server key in Hive: $e\n$st');
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('Error fetching server key: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
