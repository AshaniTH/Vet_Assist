import 'package:flutter/material.dart';
import 'pw_faild.dart'; // Make sure this file has class PwFaildPage

class PasswordUpdatedPage extends StatelessWidget {
  const PasswordUpdatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Password\nUpdated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007C85),
                ),
              ),
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF007C85),
                child: Icon(Icons.check, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'your password has\nbeen updated',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PwFaildPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007C85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 14.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
