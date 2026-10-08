// ignore_for_file: avoid_print



import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:live_chat/Controller/handel_notification.dart';
import 'package:live_chat/Controller/langauge_controller.dart'; 

import 'package:live_chat/Controller/network_controller.dart';
import 'package:live_chat/Core/Class/api.dart';
import 'package:live_chat/Core/initial_bindings.dart';
import 'package:live_chat/View/Screens/splash/splash_screen.dart';
import 'package:live_chat/firebase_options.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/screen_go.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_chat/Core/Class/dynamic_link_service.dart';

SharedPreferences? sharedPreferences;
bool? pref;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyBXoxdZGdgH8ORanE8x9jgiu0n7s9buFCc",
              authDomain: "ngoum-cf658.firebaseapp.com",
              projectId: "ngoum-cf658",
              storageBucket: "ngoum-cf658.firebasestorage.app",
              messagingSenderId: "273991677038",
              appId: "1:273991677038:web:d71d9b0e9a53fd6b23a27f",
              measurementId: "G-DBVLDMKBXK"));
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print("device token>>>>> ${sharedPreferences!.getString("deviceToken")}");
    print("device id>>>>> ${sharedPreferences!.getString("deviceId")}");
    print("token>>>>> ${sharedPreferences!.getString("token")}");

    print("✅ Firebase initialized successfully");

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }

    final firebaseNotification = FirebaseNotification();

    if (!kIsWeb) {
      await firebaseNotification.firebasemessaginsetting();
      await firebaseNotification.intilizeNotification();
    }
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  sharedPreferences!.getBool("isDarkMode") ??
      await sharedPreferences!.setBool("isDarkMode", false);
  pref = sharedPreferences!.getBool("isDarkMode")!;

  final String initialLocale =
      sharedPreferences!.getString("selectedLanguage") ?? 'ar';
  await sharedPreferences!.setString("selectedLanguage", initialLocale);
  Get.put(Api());

  Get.put(AppSettingsController());
Get.put(NetworkController(), permanent: true);
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MyApp(initialLocale: initialLocale),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenGo(
      materialApp: true,
      builder: (context, deviceInfo) => GetBuilder<AppSettingsController>(
        init: AppSettingsController(),
        builder: (controller) => GetMaterialApp(
          onInit: () {
            DynamicLinkService.initDynamicLinks(); 
            
          },
          initialBinding: InitialBindings(), 
          
          builder: DevicePreview.appBuilder,
          useInheritedMediaQuery: true,


          locale: Locale(controller.selectedLanguage.value),
          fallbackLocale: const Locale('ar'),

          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
