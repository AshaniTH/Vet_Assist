import 'package:flutter/material.dart';
import 'package:vet_assist/login.dart';
import 'package:vet_assist/signin.dart';
import 'package:vet_assist/splash.dart';
import 'package:vet_assist/start.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const Splash(),
        '/start': (context) => const Start(),
        '/signin': (context) => const SignInScreen(),
        '/login': (context) => const LoginScreen(),
        // '/profile': (context) => const
      },
      home: const Splash(),
    );
  }
}
