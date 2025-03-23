import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // นำเข้าแพ็คเกจการแจ้งเตือน
import 'pages/login.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Ensure Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA8CDNzsvQe2eeHOq9muNJo6BNAnzEbhhY',
      appId: '1:385178959327:android:cb500c04da3990372d186a',
      messagingSenderId: "385178959327",
      projectId: "exproj-7a9b3",
      storageBucket: "exproj-7a9b3.appspot.com",
    ),
  );

  // Initializing notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginScreen(), // เปลี่ยนไปยังหน้าจอที่ต้องการ
    );
  }
}
