import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patients_info.dart';

class PatientService {
  final CollectionReference patientsCollection =
      FirebaseFirestore.instance.collection('patients');

  Future<List<Patient>> getPatients() async {
    QuerySnapshot querySnapshot = await patientsCollection.get();
    List<Patient> patients = [];

    querySnapshot.docs.forEach((doc) {
      //patients.add(Patient.fromMap(doc.data(), doc.id));
    });

    return patients;
  }
}
