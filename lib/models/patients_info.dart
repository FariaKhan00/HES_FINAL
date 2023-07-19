class Patient {
  final String? patientid;
  final String? patientname;
  final int? patientage;
  final String? symptoms;

  Patient({this.patientage, this.patientname, this.patientid, this.symptoms});

  factory Patient.fromMap(Map<String, dynamic> map, String id) {
    return Patient(
      patientid: id,
      patientname: map['patient name'],
      patientage: map['patient age'],
      symptoms: map['symptoms'],
    );
  }
}
