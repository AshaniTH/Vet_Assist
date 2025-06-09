import 'package:cloud_firestore/cloud_firestore.dart';

class WeightEntry {
  final String? id;
  final String petId;
  final double weight;
  final DateTime date;
  final String? notes;
  final String? bodyCondition; // Optional: body condition score

  WeightEntry({
    this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
    this.bodyCondition,
  });

  factory WeightEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightEntry(
      id: doc.id,
      petId: data['petId'] as String,
      weight: (data['weight'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      bodyCondition: data['bodyCondition'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'weight': weight,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'bodyCondition': bodyCondition,
      'createdAt': Timestamp.now(),
    };
  }

  WeightEntry copyWith({
    String? id,
    String? petId,
    double? weight,
    DateTime? date,
    String? notes,
    String? bodyCondition,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      bodyCondition: bodyCondition ?? this.bodyCondition,
    );
  }
}
