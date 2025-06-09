import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_assist/e_clinic_book/meal/food_model.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_service.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class FoodDatabasePage extends StatelessWidget {
  final Pet pet;

  const FoodDatabasePage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Database'),
        backgroundColor: const Color(0xFF219899),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFoodDialog(context),
          ),
        ],
      ),
      body: Consumer<MealService>(
        builder: (context, mealService, child) {
          return StreamBuilder<List<FoodItem>>(
            stream: mealService.getFoodItems(pet.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final foodItems = snapshot.data ?? [];

              if (foodItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fastfood,
                        size: 60,
                        color: Color(0xFF219899),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No food items added yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showAddFoodDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF219899),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add First Food Item'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final foodItem = foodItems[index];
                  return _FoodItemCard(pet: pet, foodItem: foodItem);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddFoodDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final brandController = TextEditingController();
    final caloriesController = TextEditingController();
    final servingSizeController = TextEditingController();
    final nutritionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Food'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Food Name*'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type*',
                    hintText: 'Dry, Wet, Raw, etc.',
                  ),
                ),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories per serving',
                    suffixText: 'kcal',
                  ),
                ),
                TextField(
                  controller: servingSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Serving size',
                    suffixText: 'grams',
                  ),
                ),
                TextField(
                  controller: nutritionController,
                  decoration: const InputDecoration(
                    labelText: 'Nutritional Info',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    typeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final foodItem = FoodItem(
                    name: nameController.text,
                    type: typeController.text,
                    brand:
                        brandController.text.isEmpty
                            ? null
                            : brandController.text,
                    caloriesPerServing:
                        caloriesController.text.isEmpty
                            ? null
                            : double.tryParse(caloriesController.text),
                    servingSize:
                        servingSizeController.text.isEmpty
                            ? null
                            : double.tryParse(servingSizeController.text),
                    nutritionalInfo:
                        nutritionController.text.isEmpty
                            ? null
                            : nutritionController.text,
                  );

                  await Provider.of<MealService>(
                    context,
                    listen: false,
                  ).addFoodItem(pet.id!, foodItem);

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add food: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF219899),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final Pet pet;
  final FoodItem foodItem;

  const _FoodItemCard({required this.pet, required this.foodItem});

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
                  foodItem.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    foodItem.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: foodItem.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    Provider.of<MealService>(
                      context,
                      listen: false,
                    ).updateFoodItem(
                      pet.id!,
                      foodItem.copyWith(isFavorite: !foodItem.isFavorite),
                    );
                  },
                ),
              ],
            ),
            if (foodItem.brand != null) ...[
              const SizedBox(height: 4),
              Text(
                'Brand: ${foodItem.brand}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Type: ${foodItem.type}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (foodItem.caloriesPerServing != null) ...[
              const SizedBox(height: 4),
              Text(
                '${foodItem.caloriesPerServing} kcal per ${foodItem.servingSize ?? 1}g serving',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (foodItem.nutritionalInfo != null) ...[
              const SizedBox(height: 8),
              Text(
                foodItem.nutritionalInfo!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
