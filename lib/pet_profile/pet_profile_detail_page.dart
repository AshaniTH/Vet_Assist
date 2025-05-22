import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:vet_assist/pet_profile/pet_profile_edit.dart';
import 'package:vet_assist/pet_profile/pet_service.dart';

class PetProfileDetailPage extends StatefulWidget {
  final Pet pet;

  const PetProfileDetailPage({super.key, required this.pet});

  @override
  State<PetProfileDetailPage> createState() => _PetProfileDetailPageState();
}

class _PetProfileDetailPageState extends State<PetProfileDetailPage> {
  late Pet _currentPet;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;
  }

  Future<void> _addImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final petService = Provider.of<PetService>(context, listen: false);
      final imageUrl = await petService.uploadPetImage(
        _currentPet.id!,
        image.path as File,
      );
      await petService.addPetImage(_currentPet.id!, imageUrl);

      setState(() {
        _currentPet = _currentPet.copyWith(
          imageUrls: [..._currentPet.imageUrls, imageUrl],
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(_currentPet.name),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetProfileEditPage(pet: _currentPet),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pet Gallery
            SizedBox(
              height: 250,
              child:
                  _currentPet.imageUrls.isNotEmpty
                      ? PageView.builder(
                        itemCount: _currentPet.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            _currentPet.imageUrls[index],
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.pets,
                              size: 60,
                              color: Color(0xFF219899),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF219899),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Photo'),
                            ),
                          ],
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Section
                  _buildInfoCard(
                    icon: Icons.info,
                    title: 'Basic Information',
                    children: [
                      _buildInfoRow('Name', _currentPet.name),
                      _buildInfoRow('Type', _currentPet.type),
                      _buildInfoRow('Breed', _currentPet.breed ?? 'Unknown'),
                      _buildInfoRow('Gender', _currentPet.gender),
                      _buildInfoRow(
                        'Age',
                        '${DateTime.now().difference(_currentPet.dob).inDays ~/ 365} years',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Physical Attributes
                  _buildInfoCard(
                    icon: Icons.assignment_ind,
                    title: 'Physical Attributes',
                    children: [
                      _buildInfoRow('Color', _currentPet.color ?? 'Unknown'),
                      _buildInfoRow(
                        'Weight',
                        _currentPet.weight != null
                            ? '${_currentPet.weight} kg'
                            : 'Unknown',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Reminders
                  _buildInfoCard(
                    icon: Icons.notifications,
                    title: 'Reminders',
                    children: [
                      _buildSwitchRow(
                        'Birthday Reminder',
                        _currentPet.birthdayReminder,
                        (value) {
                          setState(() {
                            _currentPet = _currentPet.copyWith(
                              birthdayReminder: value,
                            );
                          });
                          Provider.of<PetService>(
                            context,
                            listen: false,
                          ).updatePetProfile(_currentPet);
                        },
                      ),
                      _buildSwitchRow(
                        'Weight Tracking',
                        _currentPet.weightReminder,
                        (value) {
                          setState(() {
                            _currentPet = _currentPet.copyWith(
                              weightReminder: value,
                            );
                          });
                          Provider.of<PetService>(
                            context,
                            listen: false,
                          ).updatePetProfile(_currentPet);
                        },
                      ),
                      _buildSwitchRow(
                        'Vaccination',
                        _currentPet.vaccinationReminder,
                        (value) {
                          setState(() {
                            _currentPet = _currentPet.copyWith(
                              vaccinationReminder: value,
                            );
                          });
                          Provider.of<PetService>(
                            context,
                            listen: false,
                          ).updatePetProfile(_currentPet);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Gallery Section
                  _buildInfoCard(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    children: [
                      if (_currentPet.imageUrls.isEmpty)
                        const Center(child: Text('No images added yet'))
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _currentPet.imageUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show full screen image
                              },
                              child: Image.network(
                                _currentPet.imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ElevatedButton(
                        onPressed: _addImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF219899),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add More Photos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF219899)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Switch(
            value: value,
            activeColor: const Color(0xFF219899),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
