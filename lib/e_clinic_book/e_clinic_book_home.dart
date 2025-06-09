import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:vet_assist/pet_profile/pet_service.dart';
import 'package:vet_assist/e_clinic_book/e_clinic_pet_page.dart';

class EClinicHomePage extends StatelessWidget {
  const EClinicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('E-Clinic Book'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
      ),
      body: Consumer<PetService>(
        builder: (context, petService, child) {
          return StreamBuilder<List<Pet>>(
            stream: petService.getPets(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final pets = snapshot.data ?? [];

              if (pets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pets,
                        size: 60,
                        color: Color(0xFF219899),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No pets added yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF219899),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Your First Pet'),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Your Pet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF219899),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return _PetEClinicCard(pet: pet);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PetEClinicCard extends StatelessWidget {
  final Pet pet;

  const _PetEClinicCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EClinicPetPage(pet: pet)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    pet.imageUrls.isNotEmpty
                        ? Image.network(
                          pet.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.type} • ${pet.breed ?? 'Unknown breed'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
