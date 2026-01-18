import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hassankamran/firebase_options.dart';
import 'package:hassankamran/styles/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:hassankamran/styles/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(initialScreen: '_'),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const HomePage(initialScreen: 'about'),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const HomePage(initialScreen: 'posts'),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) {
        final projectId = state.uri.queryParameters['id'];
        return HomePage(initialScreen: 'projects', projectId: projectId);
      },
    ),
    GoRoute(
      path: '/resume',
      builder: (context, state) => const HomePage(initialScreen: 'resume'),
    ),
    GoRoute(
      path: '/more',
      builder: (context, state) => const HomePage(initialScreen: 'more'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      // Reduce unnecessary repaints
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
    );
  }
}
