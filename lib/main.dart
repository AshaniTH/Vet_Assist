import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vet_assist/forgot_password_email.dart';
import 'package:vet_assist/login.dart';
import 'package:vet_assist/option.dart';
import 'package:vet_assist/pet_profile/pet_profile_create.dart';
import 'package:vet_assist/pet_profile/pet_profile_home.dart';
import 'package:vet_assist/signin.dart';
import 'package:vet_assist/splash.dart';
import 'package:vet_assist/start.dart';
import 'package:vet_assist/verification_pending.dart';

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
        '/forgot_password': (context) => const ForgotPasswordEmailPage(),
        '/verification': (context) => const VerificationPendingPage(),
        '/I updated my password': (context) => const LoginScreen(),

        '/pet_profile_home': (context) => const PetProfileHomePage(),
        '/pet_profile_create':
            (context) => const PetProfileCreatePage(petType: ''),
        '/option': (context) => const HomePage(),
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
