import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vet_assist/verification_pending.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is verified when building the home page
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerificationPendingPage(),
          ),
        );
      });
    }

    void handleAvatarButton() {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile button tapped!')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF219899),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 32),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: handleAvatarButton,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage(
                    'images/pngwing.com (68).png',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              FeatureCard(
                iconPath: 'images/baluadiya.png',
                title: 'Pet Profile',
                subtitle: "All your pet's details in one place!",
                color: const Color(0xFF219899),
                textColor: Colors.white,
                shadow: false,
                onTap: () {},
              ),
              const SizedBox(height: 18),
              FeatureCard(
                iconPath: 'images/bot.png',
                title: 'Vet Assist\nChat bot',
                subtitle: 'Smart vet chatbot care made easy!',
                color: Colors.white,
                textColor: const Color(0xFF219899),
                shadow: true,
                onTap: () {},
              ),
              const SizedBox(height: 18),
              FeatureCard(
                iconPath: 'images/book.png',
                title: 'E clinic\nbook',
                subtitle: 'Your go-to guide for pet health!',
                color: const Color(0xFF219899),
                textColor: Colors.white,
                shadow: false,
                onTap: () {},
              ),
              const SizedBox(height: 18),
              FeatureCard(
                iconPath: 'images/location.png',
                title: 'Near by\nClinic',
                subtitle: 'Locate the best vets near you!',
                color: Colors.white,
                textColor: const Color(0xFF219899),
                shadow: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 54,
        color: const Color(0xFF219899),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final bool shadow;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Set a fixed height for all cards to keep them the same size
    return SizedBox(
      height: 110, // Adjust as needed for your design
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        elevation: shadow ? 8 : 0,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 18.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center text vertically
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor.withOpacity(0.87),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
