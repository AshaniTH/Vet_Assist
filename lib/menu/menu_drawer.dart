import 'package:flutter/material.dart';
import 'package:vet_assist/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vet_assist/pet_profile/pet_list_page.dart';
import 'package:vet_assist/pet_profile/pet_profile_home.dart';
import 'package:vet_assist/user_profile/user_profile_page.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF00838F);
    final textColor = Colors.white;

    return Drawer(
      backgroundColor: primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage(
                    'images/pngwing.com (68).png',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.pets,
            title: 'Pet Profile',
            onTap: () {
              Navigator.pop(context);
              var push = Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetListPage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.add,
            title: 'Add Pet',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PetProfileHomePage(),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.chat,
            title: 'Chat Bot',
            onTap: () {
              Navigator.pop(context);
              // Navigate to Chat Bot page
              // Navigator.push(...);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings page
              // Navigator.push(...);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.book,
            title: 'E Clinic Book',
            onTap: () {
              Navigator.pop(context);
              // Navigate to E Clinic Book page
              // Navigator.push(...);
            },
          ),
          _buildListTile(
            context,
            icon: Icons.location_on,
            title: 'Near by Clinic',
            onTap: () {
              Navigator.pop(context);
              // Navigate to Nearby Clinic page
              // Navigator.push(...);
            },
          ),
          const Divider(color: Colors.white54),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Log out',
            onTap: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class pet_profile {
  const pet_profile();
}

class PetProfilePage {
  const PetProfilePage();
}
