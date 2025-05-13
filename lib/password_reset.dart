import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'password_updated.dart'; // Assuming this file contains PasswordUpdatedPage

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF007C85),
      prefixIcon: const Icon(Icons.lock, color: Colors.white),
      hintStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
    // In password_reset.dart

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                obscureText: true,
                decoration: inputDecoration.copyWith(hintText: 'New Password'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: inputDecoration.copyWith(
                  hintText: 'Confirm Password',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Password Updated screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordUpdatedPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007C85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 14.0,
                  ),
                ),
                child: const Text(
                  'Update Password',
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
