import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vet_assist/login.dart';
import 'package:vet_assist/option.dart';
import 'package:vet_assist/signin.dart';
import 'package:vet_assist/splash.dart';
import 'package:vet_assist/start.dart';
import 'package:vet_assist/verification_pending.dart';
import 'password_reset.dart'; // Assuming this file defines ResetPasswordPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/verification': (context) => const VerificationPendingPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splash();
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return user.emailVerified ? HomePage() : VerificationPendingPage();
          }
          return const Start();
        },
      ), // Change to ResetPasswordPage() for testing if needed
    );
  }
}
