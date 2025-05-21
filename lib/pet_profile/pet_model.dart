import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String? id;
  final String userId;
  final String name;
  final String type;
  final String gender;
  final DateTime dob;
  final String? breed;
  final double? weight;
  final String? color;
  final List<String> imageUrls;
  final bool birthdayReminder;
  final bool weightReminder;
  final bool vaccinationReminder;

  Pet({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.gender,
    required this.dob,
    this.breed,
    this.weight,
    this.color,
    List<String>? imageUrls,
    this.birthdayReminder = false,
    this.weightReminder = false,
    this.vaccinationReminder = false,
  }) : imageUrls = imageUrls ?? [];

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      gender: data['gender'] as String,
      dob: (data['dob'] as Timestamp).toDate(),
      breed: data['breed'] as String?,
      weight: data['weight']?.toDouble(),
      color: data['color'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      birthdayReminder: data['birthdayReminder'] as bool? ?? false,
      weightReminder: data['weightReminder'] as bool? ?? false,
      vaccinationReminder: data['vaccinationReminder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'gender': gender,
      'dob': Timestamp.fromDate(dob),
      'breed': breed,
      'weight': weight,
      'color': color,
      'imageUrls': imageUrls,
      'birthdayReminder': birthdayReminder,
      'weightReminder': weightReminder,
      'vaccinationReminder': vaccinationReminder,
      'createdAt': Timestamp.now(),
    };
  }

  Pet copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? gender,
    DateTime? dob,
    String? breed,
    double? weight,
    String? color,
    List<String>? imageUrls,
    bool? birthdayReminder,
    bool? weightReminder,
    bool? vaccinationReminder,
  }) {
    return Pet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      imageUrls: imageUrls ?? this.imageUrls,
      birthdayReminder: birthdayReminder ?? this.birthdayReminder,
      weightReminder: weightReminder ?? this.weightReminder,
      vaccinationReminder: vaccinationReminder ?? this.vaccinationReminder,
    );
  }
}
