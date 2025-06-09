import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vet_assist/e_clinic_book/meal/food_database.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_day_planner.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class MealPlannerHomePage extends StatefulWidget {
  final Pet pet;

  const MealPlannerHomePage({super.key, required this.pet});

  @override
  State<MealPlannerHomePage> createState() => _MealPlannerHomePageState();
}

class _MealPlannerHomePageState extends State<MealPlannerHomePage> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.fastfood),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDatabasePage(pet: widget.pet),
                ),
              );
            },
          ),
        ],
      ),
      body: MealDayPlannerPage(pet: widget.pet, date: _selectedDate),
    );
  }
}
