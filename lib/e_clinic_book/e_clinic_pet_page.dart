import 'package:flutter/material.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_planner_home.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_list.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_list.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class EClinicPetPage extends StatelessWidget {
  final Pet pet;

  const EClinicPetPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text("${pet.name}'s E-Clinic Book"),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPetHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    icon: Icons.medical_services,
                    title: 'Vaccination\nSchedule',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VaccinationListPage(pet: pet),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.monitor_weight,
                    title: 'Weight\nTracker',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeightListPage(pet: pet),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.restaurant,
                    title: 'Meal\nPlanner',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealPlannerHomePage(pet: pet),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.medical_information,
                    title: 'Medical\nRecords',
                    onTap: () {
                      // TODO: Implement medical records navigation
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              pet.imageUrls.isNotEmpty
                  ? NetworkImage(pet.imageUrls.first)
                  : null,
          child:
              pet.imageUrls.isEmpty
                  ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                  : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF219899),
              ),
            ),
            Text(
              '${pet.type} • ${pet.breed ?? 'Unknown breed'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              'Age: ${_calculateAge(pet.dob)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}';
    } else {
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
              Icon(icon, size: 40, color: const Color(0xFF219899)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF219899),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
