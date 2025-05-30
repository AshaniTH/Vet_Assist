import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vet_assist/e_clinic_book/vaccination/vaccination_model.dart';

class VaccinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Vaccination>> getVaccinations(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .orderBy('dateGiven', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Vaccination.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> addVaccination(String petId, Vaccination vaccination) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .add(vaccination.toFirestore());
  }

  Future<void> updateVaccination(String petId, Vaccination vaccination) async {
    if (vaccination.id == null) throw Exception('Vaccination ID is null');
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccination.id)
        .update(vaccination.toFirestore());
  }

  Future<void> deleteVaccination(String petId, String vaccinationId) async {
    await _firestore
        .collection('pets')
        .doc(petId)
        .collection('vaccinations')
        .doc(vaccinationId)
        .delete();
  }

  Future<List<Vaccination>> getUpcomingVaccinations(String petId) async {
    final snapshot =
        await _firestore
            .collection('pets')
            .doc(petId)
            .collection('vaccinations')
            .where('nextDate', isGreaterThan: Timestamp.now())
            .where('reminderEnabled', isEqualTo: true)
            .orderBy('nextDate')
            .get();

    return snapshot.docs.map((doc) => Vaccination.fromFirestore(doc)).toList();
  }
}
