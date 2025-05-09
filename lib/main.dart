import 'package:flutter/material.dart';
import 'package:vet_assist/login.dart';
import 'package:vet_assist/signin.dart';
import 'package:vet_assist/splash.dart';
import 'package:vet_assist/start.dart';
import 'password_reset.dart'; // Assuming this file exists and defines ResetPasswordPage

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
        '/reset_password': (context) => const ResetPasswordPage(),
      },
      home: const Splash(), // Change to ResetPasswordPage() here if needed temporarily
    );
  }
}
