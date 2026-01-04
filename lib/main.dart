import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hassankamran/firebase_options.dart';
import 'package:hassankamran/styles/app_theme.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: true,
      home: const HomePage(),
    );
  }
}
