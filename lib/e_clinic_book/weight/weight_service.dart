import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_assist/e_clinic_book/models/weight_model.dart';

class WeightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<WeightEntry>> getWeightEntries(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('weight_entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WeightEntry.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<List<WeightEntry>> getWeightEntriesForChart(String petId) async {
    final snapshot =
        await _firestore
            .collection('pets')
            .doc(petId)
            .collection('weight_entries')
            .orderBy('date')
            .get();

    return snapshot.docs.map((doc) => WeightEntry.fromFirestore(doc)).toList();
  }

  Future<void> addWeightEntry(String petId, WeightEntry entry) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('weight_entries')
        .add(entry.toFirestore());
  }

  Future<void> updateWeightEntry(String petId, WeightEntry entry) async {
    if (entry.id == null) throw Exception('Weight entry ID is null');
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('weight_entries')
        .doc(entry.id)
        .update(entry.toFirestore());
  }

  Future<void> deleteWeightEntry(String petId, String entryId) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('weight_entries')
        .doc(entryId)
        .delete();
  }
}
