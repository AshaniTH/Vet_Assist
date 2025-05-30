import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String? id;
  final String petId;
  final String name;
  final DateTime dateGiven;
  final DateTime? nextDate;
  final String? notes;
  final bool reminderEnabled;

  Vaccination({
    this.id,
    required this.petId,
    required this.name,
    required this.dateGiven,
    this.nextDate,
    this.notes,
    this.reminderEnabled = true,
  });

  factory Vaccination.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vaccination(
      id: doc.id,
      petId: data['petId'] as String,
      name: data['name'] as String,
      dateGiven: (data['dateGiven'] as Timestamp).toDate(),
      nextDate:
          data['nextDate'] != null
              ? (data['nextDate'] as Timestamp).toDate()
              : null,
      notes: data['notes'] as String?,
      reminderEnabled: data['reminderEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'name': name,
      'dateGiven': Timestamp.fromDate(dateGiven),
      'nextDate': nextDate != null ? Timestamp.fromDate(nextDate!) : null,
      'notes': notes,
      'reminderEnabled': reminderEnabled,
      'createdAt': Timestamp.now(),
    };
  }

  Vaccination copyWith({
    String? id,
    String? petId,
    String? name,
    DateTime? dateGiven,
    DateTime? nextDate,
    String? notes,
    bool? reminderEnabled,
  }) {
    return Vaccination(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      dateGiven: dateGiven ?? this.dateGiven,
      nextDate: nextDate ?? this.nextDate,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }
}
