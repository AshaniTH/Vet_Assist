import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_service.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this
import 'package:vet_assist/forgot_password_email.dart';
import 'package:vet_assist/login.dart';
import 'package:vet_assist/option.dart';
import 'package:vet_assist/pet_profile/pet_profile_create.dart';
import 'package:vet_assist/pet_profile/pet_profile_home.dart';
import 'package:vet_assist/pet_profile/pet_service.dart';
import 'package:vet_assist/signin.dart';
import 'package:vet_assist/splash.dart';
import 'package:vet_assist/start.dart';
import 'package:vet_assist/verification_pending.dart';
import 'package:vet_assist/nearby_vets.dart';
import 'package:vet_assist/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "api.env"); // ✅ Load environment file
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PetService()),
        Provider(create: (_) => VaccinationService()),
        Provider<WeightService>(create: (_) => WeightService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vet Assist',
      theme: ThemeData(
        primaryColor: const Color(0xFF219899),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF219899),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      routes: {
        '/splash': (context) => const Splash(),
        '/start': (context) => const Start(),
        '/signin': (context) => const SignInScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordEmailPage(),
        '/verification': (context) => const VerificationPendingPage(),
        '/I updated my password': (context) => const LoginScreen(),

        '/pet_profile_home': (context) => const PetProfileHomePage(),
        '/pet_profile_create': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PetProfileCreatePage(petType: args['petType']);
        },
        '/option': (context) => const HomePage(),
        '/nearby_vets': (context) => NearbyVetHospitalsPage(), // ✅ Add route
        '/nearby_vets': (context) => NearbyVetHospitalsPage(),
        '/chat': (context) => ChatScreen(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Splash();
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return user.emailVerified
                ? const HomePage()
                : const VerificationPendingPage();
          }
          return const Start();
        },
      ),
    );
  }
}
