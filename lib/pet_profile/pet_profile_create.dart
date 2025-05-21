import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/pet_profile/pet_list_page.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';
import 'package:vet_assist/pet_profile/pet_service.dart';

class PetProfileCreatePage extends StatefulWidget {
  final String petType;

  const PetProfileCreatePage({super.key, required this.petType});

  @override
  State<PetProfileCreatePage> createState() => _PetProfileCreatePageState();
}

class _PetProfileCreatePageState extends State<PetProfileCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _birthdayReminder = true;
  bool _weightReminder = false;
  bool _vaccinationReminder = false;

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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createPetProfile() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedGender != null) {
      try {
        final pet = Pet(
          userId: '', // Will be set by PetService
          name: _nameController.text,
          type: widget.petType,
          gender: _selectedGender!,
          dob: _selectedDate!,
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
        await petService.addPetProfile(pet);

        // Navigate back to PetListPage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PetListPage()),
          (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create pet profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Add ${widget.petType} Profile'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,

        elevation: 0,
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
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
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
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                  ),
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
                  labelText: '${widget.petType} Breed',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {
                      // Show breed suggestions
                    },
                  ),
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
              const SizedBox(height: 30),

              // Create Button
              ElevatedButton(
                onPressed: _createPetProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF219899),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Pet Profile',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
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
