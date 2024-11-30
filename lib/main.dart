import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/user/home_page.dart';
import 'pages/user/main_page.dart';

// Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();
  Widget _defaultPage = const HomePage(); // Default page if no user is logged in

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize FCM
    await _notificationService.init();

    // Check if the user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _defaultPage = const MainPage(selectedIndex: 1); // Navigate to MainPage if logged in
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey, // Assign the global navigator key
      home: _defaultPage, // Navigate to the appropriate default page
    );
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request notification permissions (iOS only)
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    // Get the device FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // Save the token to the backend or display it for testing
    }

    // Handle messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick();
    });
  }

  void _handleNotificationClick() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, navigate to MainPage
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage(selectedIndex: 1)),
        (route) => false,
      );
    } else {
      // If user is not logged in, navigate to HomePage
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }
}
