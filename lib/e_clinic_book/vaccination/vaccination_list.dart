import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_form.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_model.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_service.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:intl/intl.dart';

class VaccinationListPage extends StatelessWidget {
  final Pet pet;

  const VaccinationListPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${pet.name}'s Vaccinations"),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VaccinationFormPage(pet: pet),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Vaccination>>(
        stream: Provider.of<VaccinationService>(
          context,
        ).getVaccinations(pet.id!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vaccinations = snapshot.data ?? [];

          if (vaccinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Color(0xFF219899),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No vaccinations recorded yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VaccinationFormPage(pet: pet),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF219899),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add First Vaccination'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaccinations.length,
            itemBuilder: (context, index) {
              final vaccination = vaccinations[index];
              return _VaccinationCard(pet: pet, vaccination: vaccination);
            },
          );
        },
      ),
    );
  }
}

class _VaccinationCard extends StatelessWidget {
  final Pet pet;
  final Vaccination vaccination;

  const _VaccinationCard({required this.pet, required this.vaccination});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final vaccinationService = Provider.of<VaccinationService>(
      context,
      listen: false,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vaccination.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF219899),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: const Color(0xFF219899),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VaccinationFormPage(
                                  pet: pet,
                                  vaccination: vaccination,
                                ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed:
                          () => _showDeleteDialog(context, vaccinationService),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Given on: ${dateFormat.format(vaccination.dateGiven)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (vaccination.nextDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next dose: ${dateFormat.format(vaccination.nextDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${vaccination.notes}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  size: 16,
                  color:
                      vaccination.reminderEnabled
                          ? const Color(0xFF219899)
                          : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  vaccination.reminderEnabled
                      ? 'Reminder enabled'
                      : 'Reminder disabled',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        vaccination.reminderEnabled
                            ? const Color(0xFF219899)
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    VaccinationService service,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vaccination?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${vaccination.name}?'),
                const Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await service.deleteVaccination(pet.id!, vaccination.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${vaccination.name} has been deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete vaccination: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
