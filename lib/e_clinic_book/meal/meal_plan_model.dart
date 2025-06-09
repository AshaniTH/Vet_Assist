import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MealEntry {
  final String? id;
  final String foodId;
  final String foodName;
  final double amount; // in grams or pieces
  final TimeOfDay time;
  final String? notes;

  MealEntry({
    this.id,
    required this.foodId,
    required this.foodName,
    required this.amount,
    required this.time,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'amount': amount,
      'hour': time.hour,
      'minute': time.minute,
      'notes': notes,
    };
  }

  factory MealEntry.fromMap(String id, Map<String, dynamic> map) {
    return MealEntry(
      id: id,
      foodId: map['foodId'] as String,
      foodName: map['foodName'] as String,
      amount: map['amount']?.toDouble(),
      time: TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int),
      notes: map['notes'] as String?,
    );
  }
}

class DailyMealPlan {
  final String? id;
  final String petId;
  final DateTime date;
  final List<MealEntry> meals;
  final double? targetCalories;
  final String? notes;

  DailyMealPlan({
    this.id,
    required this.petId,
    required this.date,
    required this.meals,
    this.targetCalories,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'date': Timestamp.fromDate(date),
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'targetCalories': targetCalories,
      'notes': notes,
      'createdAt': Timestamp.now(),
    };
  }

  factory DailyMealPlan.fromMap(String id, Map<String, dynamic> map) {
    return DailyMealPlan(
      id: id,
      petId: map['petId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      meals:
          (map['meals'] as List<dynamic>)
              .map((meal) => MealEntry.fromMap('', meal))
              .toList(),
      targetCalories: map['targetCalories']?.toDouble(),
      notes: map['notes'] as String?,
    );
  }
}
