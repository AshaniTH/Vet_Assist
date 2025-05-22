import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:vet_assist/pet_profile/pet_service.dart';

class PetProfileEditPage extends StatefulWidget {
  final Pet pet;

  const PetProfileEditPage({super.key, required this.pet});

  @override
  State<PetProfileEditPage> createState() => _PetProfileEditPageState();
}

class _PetProfileEditPageState extends State<PetProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _colorController;
  late DateTime _selectedDate;
  late String _selectedGender;
  late bool _birthdayReminder;
  late bool _weightReminder;
  late bool _vaccinationReminder;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed ?? '');
    _weightController = TextEditingController(
      text: widget.pet.weight?.toString() ?? '',
    );
    _colorController = TextEditingController(text: widget.pet.color ?? '');
    _selectedDate = widget.pet.dob;
    _selectedGender = widget.pet.gender;
    _birthdayReminder = widget.pet.birthdayReminder;
    _weightReminder = widget.pet.weightReminder;
    _vaccinationReminder = widget.pet.vaccinationReminder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updatePetProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedPet = widget.pet.copyWith(
          name: _nameController.text,
          gender: _selectedGender,
          dob: _selectedDate,
          breed: _breedController.text.isEmpty ? null : _breedController.text,
          weight:
              _weightController.text.isEmpty
                  ? null
                  : double.tryParse(_weightController.text),
          color: _colorController.text.isEmpty ? null : _colorController.text,
          birthdayReminder: _birthdayReminder,
          weightReminder: _weightReminder,
          vaccinationReminder: _vaccinationReminder,
        );

        final petService = Provider.of<PetService>(context, listen: false);
        await petService.updatePetProfile(updatedPet);

        Navigator.pop(context); // Go back to detail page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update pet profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Edit Pet Profile'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePetProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Info Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              // Pet Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Selection
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.male),
                ),
                items:
                    ['Male', 'Female'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Info Section
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),

              // Breed
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: '${widget.pet.type} Breed',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color/Markings',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
              ),
              const SizedBox(height: 16),

              // Reminders Section
              _buildSectionHeader('Reminders'),
              const SizedBox(height: 8),

              // Birthday Reminder
              SwitchListTile(
                title: const Text('Birthday Reminder'),
                value: _birthdayReminder,
                activeColor: const Color(0xFF219899),
                onChanged: (value) {
                  setState(() {
                    _birthdayReminder = value;
                  });
                },
              ),

              // Weight Tracking Reminder
              SwitchListTile(
                title: const Text('Weight Tracking Reminder'),
                value: _weightReminder,
                activeColor: const Color(0xFF219899),
                onChanged: (value) {
                  setState(() {
                    _weightReminder = value;
                  });
                },
              ),

              // Vaccination Reminder
              SwitchListTile(
                title: const Text('Vaccination Reminder'),
                value: _vaccinationReminder,
                activeColor: const Color(0xFF219899),
                onChanged: (value) {
                  setState(() {
                    _vaccinationReminder = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF219899),
      ),
    );
  }
}
