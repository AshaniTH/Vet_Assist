import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_model.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_service.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class VaccinationFormPage extends StatefulWidget {
  final Pet pet;
  final Vaccination? vaccination;

  const VaccinationFormPage({super.key, required this.pet, this.vaccination});

  @override
  State<VaccinationFormPage> createState() => _VaccinationFormPageState();
}

class _VaccinationFormPageState extends State<VaccinationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dateGiven;
  DateTime? _nextDate;
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.vaccination != null) {
      _nameController.text = widget.vaccination!.name;
      _notesController.text = widget.vaccination!.notes ?? '';
      _dateGiven = widget.vaccination!.dateGiven;
      _nextDate = widget.vaccination!.nextDate;
      _reminderEnabled = widget.vaccination!.reminderEnabled;
    } else {
      _dateGiven = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isNextDate
              ? _dateGiven?.add(const Duration(days: 30)) ?? DateTime.now()
              : _dateGiven ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isNextDate) {
          _nextDate = picked;
        } else {
          _dateGiven = picked;
        }
      });
    }
  }

  Future<void> _saveVaccination() async {
    if (_formKey.currentState!.validate() && _dateGiven != null) {
      try {
        final vaccination = Vaccination(
          id: widget.vaccination?.id,
          petId: widget.pet.id!,
          name: _nameController.text,
          dateGiven: _dateGiven!,
          nextDate: _nextDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          reminderEnabled: _reminderEnabled,
        );

        final service = Provider.of<VaccinationService>(context, listen: false);

        if (widget.vaccination == null) {
          await service.addVaccination(widget.pet.id!, vaccination);
        } else {
          await service.updateVaccination(widget.pet.id!, vaccination);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vaccination ${widget.vaccination == null ? 'added' : 'updated'} successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save vaccination: $e'),
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
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vaccination == null ? 'Add Vaccination' : 'Edit Vaccination',
        ),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveVaccination),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccination Name*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vaccination name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Given*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateGiven != null
                        ? dateFormat.format(_dateGiven!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Dose Date (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _nextDate != null
                        ? dateFormat.format(_nextDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: _reminderEnabled,
                activeColor: const Color(0xFF219899),
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveVaccination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF219899),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.vaccination == null
                      ? 'Add Vaccination'
                      : 'Update Vaccination',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
