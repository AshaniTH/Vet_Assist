import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  double _logoOpacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller before super.dispose()
    super.dispose();
  }

  void initState() {
    super.initState();
    _navigatetohome();

    //fade in logo
    Timer(const Duration(microseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
    // loading line animation setup

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _progress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if widget is still mounted
        Navigator.pushReplacementNamed(context, '/start');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00838F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _logoOpacity,
              duration: const Duration(seconds: 4),
              child: Image.asset("assest/applogo.png"),
            ),

            const SizedBox(height: 0.25),

            const Text(
              'Vet Assist',
              style: TextStyle(
                fontSize: 48,
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // Simple animated loading line
            Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(77),

                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
