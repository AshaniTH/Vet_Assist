import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_assist/e_clinic_book/meal/food_model.dart';
import 'package:vet_assist/e_clinic_book/meal/meal_plan_model.dart';

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Food Items
  Stream<List<FoodItem>> getFoodItems(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('food_items')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FoodItem.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> addFoodItem(String petId, FoodItem foodItem) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('food_items')
        .add(foodItem.toMap());
  }

  Future<void> updateFoodItem(String petId, FoodItem foodItem) async {
    if (foodItem.id == null) throw Exception('Food item ID is null');
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('food_items')
        .doc(foodItem.id)
        .update(foodItem.toMap());
  }

  // Meal Plans
  Stream<List<DailyMealPlan>> getMealPlans(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('meal_plans')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DailyMealPlan.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<DailyMealPlan?> getMealPlanForDate(String petId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot =
        await _firestore
            .collection('pets')
            .doc(petId)
            .collection('meal_plans')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return DailyMealPlan.fromMap(
      snapshot.docs.first.id,
      snapshot.docs.first.data(),
    );
  }

  Future<void> saveMealPlan(String petId, DailyMealPlan mealPlan) async {
    if (mealPlan.id == null) {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('meal_plans')
          .add(mealPlan.toMap());
    } else {
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('meal_plans')
          .doc(mealPlan.id)
          .update(mealPlan.toMap());
    }
  }

  Future<void> deleteMealPlan(String petId, String mealPlanId) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('meal_plans')
        .doc(mealPlanId)
        .delete();
  }
}
