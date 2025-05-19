import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addPetProfile({
    required String name,
    required String type,
    required String gender,
    required DateTime dob,
    String? breed,
    double? weight,
    String? color,
    bool birthdayReminder = false,
    bool weightReminder = false,
    bool vaccinationReminder = false,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore.collection('pets').add({
        'userId': userId,
        'name': name,
        'type': type,
        'gender': gender,
        'dob': Timestamp.fromDate(dob),
        'breed': breed,
        'weight': weight,
        'color': color,
        'birthdayReminder': birthdayReminder,
        'weightReminder': weightReminder,
        'vaccinationReminder': vaccinationReminder,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add pet profile: $e');
    }
  }

  Stream<QuerySnapshot> getPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
