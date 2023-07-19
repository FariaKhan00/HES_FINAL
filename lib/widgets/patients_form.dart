import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("patients");

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      // Add patient information to Firebase
      var Patientname;
      var Symptoms;
      var Patientage;
      FirebaseFirestore.instance.collection('patients').add({
        'name': Patientname,
        'age': Patientage,
        'symptoms': Symptoms,
      });

      // Clear the form fields after submission
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? sympotms;
    int Patientage;
    String? Patientname;
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Information Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a name';
                  return null;
                },
                onSaved: (value) => Patientname = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter an age';
                  return null;
                },
                onSaved: (value) => Patientage = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Symptoms'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter symptoms';
                  return null;
                },
                onSaved: (value) => sympotms = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
