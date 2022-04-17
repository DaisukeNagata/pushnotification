import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String imageUrl = "";

  Future<String> _onMessageIos() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage messaging) async {
      debugPrint('Handling a foreground message ${messaging.messageId}');
      RemoteNotification? notification = messaging.notification;
      AppleNotification? ios = messaging.notification?.apple;

      if (notification != null && ios != null) {
        setState(() {
          imageUrl = notification.apple?.imageUrl ?? "";
        });

        final plugin = FlutterLocalNotificationsPlugin();
        return plugin
            .initialize(
              const InitializationSettings(
                iOS: IOSInitializationSettings(),
              ),
            )
            .then((_) => plugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                const NotificationDetails(iOS: IOSNotificationDetails())));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message clicked!');
    });

    return "OK";
  }

  Future<String> _onMessageAndroid() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage messaging) async {
      debugPrint('Handling a foreground message ${messaging.messageId}');
      RemoteNotification? notification = messaging.notification;
      AndroidNotification? android = messaging.notification?.android;

      if (notification != null && android != null) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
        var initializationSettingsAndroid =
            const AndroidInitializationSettings('@mipmap/ic_launcher');
        setState(() {
          imageUrl = notification.android?.imageUrl ?? "";
        });

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              // 通知channelを設定する
              android: AndroidNotificationDetails(
                  'like_channel', // channelId
                  'あなたの投稿へのコメント', // channelName,// channelDescription
                  icon: initializationSettingsAndroid.defaultIcon),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message clicked!');
    });

    return "OK";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      final getToken = await messaging.getToken();
      debugPrint(getToken ?? "");
      if ((getToken ?? "") != "") {
        if (Platform.isAndroid) {
          _onMessageAndroid();
        } else {
          _onMessageIos();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageUrl == "" ? const Text('') : Image.network(imageUrl),
          ],
        ),
      ),
    );
  }
}
