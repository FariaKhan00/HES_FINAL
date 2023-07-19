import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel {
  String? time;
  String? originAddress;
  String? destAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;

  TripHistoryModel({
    this.time,
    this.car_details,
    this.destAddress,
    this.fareAmount,
    this.driverName,
    this.originAddress,
    this.status,
  });

  TripHistoryModel.fromSnapshot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destAddress = (dataSnapshot.value as Map)["destAddress"];
    status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    driverName = (dataSnapshot.value as Map)["DriverName"];
    car_details = (dataSnapshot.value as Map)["car_details"];
  }
}
