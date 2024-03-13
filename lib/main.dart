import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:proyecto/Screens/Admin/ApproveArticle/approve_article_screen.dart';
import 'package:proyecto/Screens/Admin/Auth/admin_login_screen.dart';
import 'package:proyecto/Screens/Admin/HomeScreen/admin_home_screen.dart';
import 'package:proyecto/Screens/Admin/Topic/topic_screen.dart';
import 'package:proyecto/Screens/UserSide/home_screen.dart';
import 'package:proyecto/Screens/UserSide/welcome_screen.dart';
import 'package:proyecto/my_utilities.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  //final navigatorKey = GlobalKey<NavigatorState>();
  WidgetsFlutterBinding.ensureInitialized();
  debugPrintGestureArenaDiagnostics = false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FluroRouter router = FluroRouter();
  AppRouter.setupRouter(router);

  verfiyWhenTokenUpdate();
  //FirebaseAuth auth = FirebaseAuth.instance;
  //var user = auth.currentUser;
  String role = await initSharedPreferences();
  await initSharedPreferences();

  runApp(
    MaterialApp(
      initialRoute: getInitialRoute(),
      onGenerateRoute: (settings) {
        FirebaseAuth auth = FirebaseAuth.instance;
        var user = auth.currentUser;
        switch (settings.name) {
          case '/admin':
            return MaterialPageRoute(builder: (context) {
              if (user == null) {
                if (role == "admin") {
                  return const AdminLoginScreen();
                } else {
                  return const AdminLoginScreen();
                }
              } else {
                return const AdminHomeScreen();
              }
            });
          case '/client':
            return MaterialPageRoute(builder: (context) {
              if (role == "user") {
                if (user != null) {
                  return const HomeScreen();
                } else {
                  return const MyApp();
                }
              } else {
                return const MyApp();
              }
            });
          default:
            return MaterialPageRoute(builder: (context) {
              if (role == "user") {
                if (user != null) {
                  return const HomeScreen();
                } else {
                  return const MyApp();
                }
              } else {
                return const MyApp();
              }
            });
        }
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

String getInitialRoute() {
  return html.window.location.pathname ?? '/';
}

Future<String> initSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('role') ?? 'user';
}

class AppRouter {
  static void setupRouter(FluroRouter router) {
    router.define(
      '/admin',
      handler: Handler(handlerFunc: (_, __) {
        return const MaterialApp(home: AdminLoginScreen());
      }),
    );

    router.define(
      '/client',
      handler: Handler(handlerFunc: (_, __) {
        return const MaterialApp(home: WelcomeScreen());
      }),
    );
    router.define(
      '/',
      handler: Handler(handlerFunc: (_, __) {
        return const MaterialApp(home: WelcomeScreen());
      }),
    );
  }
}

void firebaseNotification() async {
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
  }
  final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey:
          "BLmLBGuRu-DjDhxzS4yIMir9Da1WlzaXKQAFNYBMc9FQ74q7Cwcq7SEKunQrDCIwOfH0QTa-ZbIitisoEh0qQ9w");
  print("fcmToken $fcmToken");
}

void verfiyWhenTokenUpdate() async {
  // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
  //   print("fcmToken $fcmToken");
  // }).onError((err) {
  //   print("FCM Toke Getting Error : $err");
  // });
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  switch (settings.authorizationStatus) {
    case AuthorizationStatus.authorized:
      firebaseNotification();
    case AuthorizationStatus.denied:
    case AuthorizationStatus.notDetermined:
    case AuthorizationStatus.provisional:
  }
  print('User granted permission: ${settings.authorizationStatus}');
}

class FirebaseNotifications {
  final RemoteMessage message;
  FirebaseNotifications({required this.message});
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void showFlutterNotification() async {
    print("comes here");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // if (notification != null && android != null && !kIsWeb) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title ?? "Title",
      notification?.body ?? "Body",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "123",
          "Azmat",
          channelDescription: "channel.description",
          icon: 'launch_background',
        ),
      ),
    );
//  }
  }
}
