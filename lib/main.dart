import 'package:codemaster/chatBot/chat_screen.dart';
import 'package:codemaster/views/Start/fill_profile_view.dart';
import 'package:codemaster/views/Start/login_success_view.dart';
import 'package:codemaster/views/Start/splash_view.dart';
import 'package:codemaster/views/home_view.dart';
import 'package:codemaster/widgets/bott_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
   url: 'https://noajbeuuvvlfhelifqzj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vYWpiZXV1dnZsZmhlbGlmcXpqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4NzgzOTEsImV4cCI6MjA2NDQ1NDM5MX0.DIZRKg99IME4EurdBZ0-03GK6cnuFNoQZ7y85IBJKw8', );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'CodeMaster',
          debugShowCheckedModeBanner: false,
          themeMode: currentTheme,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: SplashView(),
          // home: MainNavigation(),
        );
      },
    );
  }
}