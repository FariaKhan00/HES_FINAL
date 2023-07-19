import 'package:flutter/material.dart';
import 'package:userapp/assistants/patient_service.dart';

import '../models/patients_info.dart';

class PatientListScreen extends StatelessWidget {
  final PatientService patientService = PatientService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient List')),
      body: FutureBuilder<List<Patient>>(
        future: patientService.getPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Patient> patients = snapshot.data!;

            return ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                Patient patient = patients[index];
                return ListTile(
                  title: Text(patient.patientname!),
                  subtitle: Text(
                      'Age: ${patient.patientage}, Symptoms: ${patient.symptoms}'),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
