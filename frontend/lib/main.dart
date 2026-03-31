import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'services/property_store.dart';
import 'services/advertisement_store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAXpnuS7HHP4qoUxIs0W2Z_QOv6ifSy-18',
      appId: '1:643297373393:web:6df5992fba47584d8aa9f0',
      messagingSenderId: '643297373393',
      projectId: 'yestatehub-jsv2026project',
      authDomain: 'yestatehub-jsv2026project.firebaseapp.com',
      storageBucket: 'yestatehub-jsv2026project.firebasestorage.app',
    ),
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load saved properties and advertisements from local storage
  await PropertyStore.instance.init();
  await AdvertisementStore.instance.init();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YEstateHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const YEstateHubApp(),
    );
  }
}
