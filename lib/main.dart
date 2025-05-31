import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'package:fernandovidal/services/new_conversation_screen.dart'; // ✅ NUEVA IMPORTACIÓN

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Mensaje en background: ${message.messageId}");
}

Future<void> _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    String? token = await _messaging.getToken();
    setState(() {
      _token = token;
    });
    print("Token FCM: $_token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensaje recibido en primer plano: ${message.messageId}");
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? "Notificación"),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("La notificación abrió la app: ${message.messageId}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetWatch',
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
      routes: {
        '/new_conversation': (_) => const NewConversationScreen(), // ✅ NUEVA RUTA
      },
    );
  }
}
