import 'package:userapp/models/active_nearby_drivers.dart';

class GeoFireAssistant {
  static List<ActiveNearbyDrivers> activeNearbyDriversList = [];

  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber = activeNearbyDriversList
        .indexWhere((element) => element.driverId == driverId);

    activeNearbyDriversList.removeAt(indexNumber);
  }

  static void updateActiveNearbyDriversLocation(
      ActiveNearbyDrivers driverMove) {
    int indexNumber = activeNearbyDriversList
        .indexWhere((element) => element.driverId == driverMove.driverId);

    activeNearbyDriversList[indexNumber].locationLatitude =
        driverMove.locationLatitude;
    activeNearbyDriversList[indexNumber].locationLongitude =
        driverMove.locationLongitude;
  }
}
