import 'package:flutter/cupertino.dart';
import 'package:userapp/models/trips_history_model.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickupLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions userPickupAddress) {
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
  }

  updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
  }

  updateOverAllTripsHistoryInformation(TripHistoryModel eachTripHistory) {
    allTripsHistoryInformationList.add(eachTripHistory);
  }
}
