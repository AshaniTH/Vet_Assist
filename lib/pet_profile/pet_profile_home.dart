import 'package:flutter/material.dart';
import 'package:vet_assist/pet_profile/pet_profile_create.dart';

class PetProfileHomePage extends StatelessWidget {
  const PetProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Pet Profile'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Pet Type',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF219899),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _PetTypeCard(
                    icon: Icons.pets,
                    title: 'DOG',
                    color: const Color(0xFF219899),
                    onTap: () => _navigateToCreatePet(context, 'Dog'),
                  ),
                  _PetTypeCard(
                    icon: Icons.pets,
                    title: 'CAT',
                    color: const Color(0xFF219899),
                    onTap: () => _navigateToCreatePet(context, 'Cat'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreatePet(BuildContext context, String petType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileCreatePage(petType: petType),
      ),
    );
  }
}

class _PetTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _PetTypeCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
