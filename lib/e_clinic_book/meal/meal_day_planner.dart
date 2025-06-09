import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/meal/food_model.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_plan_model.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_service.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class MealDayPlannerPage extends StatefulWidget {
  final Pet pet;
  final DateTime date;

  const MealDayPlannerPage({super.key, required this.pet, required this.date});

  @override
  State<MealDayPlannerPage> createState() => _MealDayPlannerPageState();
}

class _MealDayPlannerPageState extends State<MealDayPlannerPage> {
  late Future<DailyMealPlan?> _mealPlanFuture;
  final _targetCaloriesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mealPlanFuture = Provider.of<MealService>(
      context,
      listen: false,
    ).getMealPlanForDate(widget.pet.id!, widget.date);
  }

  @override
  void dispose() {
    _targetCaloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMealPlan(List<MealEntry> meals) async {
    final mealService = Provider.of<MealService>(context, listen: false);
    final existingPlan = await _mealPlanFuture;

    final plan = DailyMealPlan(
      id: existingPlan?.id,
      petId: widget.pet.id!,
      date: widget.date,
      meals: meals,
      targetCalories:
          _targetCaloriesController.text.isEmpty
              ? null
              : double.tryParse(_targetCaloriesController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await mealService.saveMealPlan(widget.pet.id!, plan);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal plan saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addMealEntry(
    BuildContext context,
    List<MealEntry> meals,
    Function(List<MealEntry>) updateMeals,
  ) async {
    final foodItems =
        await Provider.of<MealService>(
          context,
          listen: false,
        ).getFoodItems(widget.pet.id!).first;

    var foodController = TextEditingController();
    final amountController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Meal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<FoodItem>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return foodItems.where(
                          (food) => food.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        );
                      },
                      displayStringForOption: (FoodItem option) => option.name,
                      fieldViewBuilder: (
                        context,
                        controller,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        foodController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Food*',
                            hintText: 'Search or enter food name',
                          ),
                        );
                      },
                      onSelected: (FoodItem selection) {
                        foodController.text = selection.name;
                      },
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount*',
                        suffixText: 'grams',
                      ),
                    ),
                    ListTile(
                      title: const Text('Time'),
                      trailing: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Special instructions',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF219899)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (foodController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newMeal = MealEntry(
                      foodId: '', // Will be updated when saving
                      foodName: foodController.text,
                      amount: double.parse(amountController.text),
                      time: selectedTime,
                      notes:
                          notesController.text.isEmpty
                              ? null
                              : notesController.text,
                    );

                    updateMeals([...meals, newMeal]);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF219899),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMM dd, yyyy').format(widget.date)),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DailyMealPlan?>(
        future: _mealPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final existingPlan = snapshot.data;
          List<MealEntry> meals = existingPlan?.meals ?? [];
          if (existingPlan != null) {
            _targetCaloriesController.text =
                existingPlan.targetCalories?.toString() ?? '';
            _notesController.text = existingPlan.notes ?? '';
          }

          return StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _targetCaloriesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Target Calories (optional)',
                        suffixText: 'kcal',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (meals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No meals planned for today',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ...meals.map(
                      (meal) => _MealEntryCard(
                        meal: meal,
                        onDelete: () {
                          setState(() {
                            meals.remove(meal);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => _addMealEntry(context, meals, (newMeals) {
                            setState(() {
                              meals = newMeals;
                            });
                          }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF219899),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Meal'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add any notes about today\'s meal plan...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _saveMealPlan(meals),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF219899),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Meal Plan'),
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

class _MealEntryCard extends StatelessWidget {
  final MealEntry meal;
  final VoidCallback onDelete;

  const _MealEntryCard({required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.foodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(meal.time.format(context)),
                const SizedBox(width: 16),
                const Icon(Icons.scale, size: 16),
                const SizedBox(width: 4),
                Text('${meal.amount}g'),
              ],
            ),
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${meal.notes}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
