import 'dart:io'; // Add this import for File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vet_assist/pet_profile/pet_model.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Unified addPetProfile method that takes a Pet object
  Future<Pet> addPetProfile(Pet pet) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final petWithUserId = pet.copyWith(userId: userId);
      final docRef = await _firestore
          .collection('pets')
          .add(petWithUserId.toFirestore());
      return petWithUserId.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to add pet profile: $e');
    }
  }

  // Single getPets method that returns Stream<List<Pet>>
  Stream<List<Pet>> getPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updatePetProfile(Pet pet) async {
    try {
      if (pet.id == null) throw Exception('Pet ID is null');
      await _firestore.collection('pets').doc(pet.id).update(pet.toFirestore());
    } catch (e) {
      throw Exception('Failed to update pet profile: $e');
    }
  }

  Future<void> deletePetProfile(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      throw Exception('Failed to delete pet profile: $e');
    }
  }

  Future<String> uploadPetImage(String petId, File imageFile) async {
    try {
      final ref = _storage.ref(
        'pet_images/$petId/${DateTime.now().millisecondsSinceEpoch}',
      );
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addPetImage(String petId, String imageUrl) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'imageUrls': FieldValue.arrayUnion([imageUrl]),
      });
    } catch (e) {
      throw Exception('Failed to add image to pet: $e');
    }
  }
}
