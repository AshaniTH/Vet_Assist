import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_model.dart';
import 'package:vet_assist/e_clinic_book/weight/weight_service.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class WeightFormPage extends StatefulWidget {
  final Pet pet;
  final WeightEntry? entry;

  const WeightFormPage({super.key, required this.pet, this.entry});

  @override
  State<WeightFormPage> createState() => _WeightFormPageState();
}

class _WeightFormPageState extends State<WeightFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _bodyConditionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _weightController.text = widget.entry!.weight.toString();
      _notesController.text = widget.entry!.notes ?? '';
      _bodyConditionController.text = widget.entry!.bodyCondition ?? '';
      _selectedDate = widget.entry!.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    _bodyConditionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWeightEntry() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final weight = double.tryParse(_weightController.text);
        if (weight == null) throw Exception('Invalid weight value');

        final entry = WeightEntry(
          id: widget.entry?.id,
          petId: widget.pet.id!,
          weight: weight,
          date: _selectedDate!,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          bodyCondition:
              _bodyConditionController.text.isEmpty
                  ? null
                  : _bodyConditionController.text,
        );

        final service = Provider.of<WeightService>(context, listen: false);

        if (widget.entry == null) {
          await service.addWeightEntry(widget.pet.id!, entry);
        } else {
          await service.updateWeightEntry(widget.pet.id!, entry);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Weight entry ${widget.entry == null ? 'added' : 'updated'} successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save weight entry: $e'),
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
          widget.entry == null ? 'Add Weight Entry' : 'Edit Weight Entry',
        ),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveWeightEntry),
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
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? dateFormat.format(_selectedDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyConditionController,
                decoration: const InputDecoration(
                  labelText: 'Body Condition (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.linear_scale),
                  hintText: 'e.g., 3/5, Ideal, etc.',
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveWeightEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF219899),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.entry == null ? 'Add Weight Entry' : 'Update Entry',
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
