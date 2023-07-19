import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:userapp/assistants/assistant_methods.dart';
import 'package:userapp/assistants/geofire_assistant.dart';
import 'package:userapp/global/global.dart';
import 'package:userapp/mainScreen/patient_list_screen.dart';
import 'package:userapp/mainScreen/rate_driver_screen.dart';
import 'package:userapp/mainScreen/search_places_screen.dart';
import 'package:userapp/mainScreen/select_online_drivers.dart';
import 'package:userapp/models/active_nearby_drivers.dart';
import 'package:userapp/widgets/patients_form.dart';

import '../infoHandler/app_info.dart';
import '../widgets/my_drawer.dart';
import '../widgets/pay_fare_amount_dialog.dart';
import '../widgets/progress_dialog.dart';





class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newgoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "Your Name";
  String userEmail = "Your Email";
  String userPhoneNo = "Your Phone Number";

  bool openNavigationDrawer = true;
  bool activeNearbyDriversKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyDrivers> onlineAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  String driverRideStatus = "Driver is on it's Way";

  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";

  bool requestPositionInfo = true;

  //FUNCTIONS

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position curPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = curPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newgoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);

    print("this is your address =$humanReadableAddress");

    userName = userModelCurrentInfo!.name!;
    userPhoneNo = userModelCurrentInfo!.phone!;

    initializeGeoFireListener();

    AssistantMethods.readTripKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  saveRideRequestInfo() {
    //save the Ride Request Info
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destLocationMap = {
      "latitude": destLocation!.locationLatitude.toString(),
      "longitude": destLocation.locationLongitude.toString(),
    };

    Map userInfoMap = {
      "origin": originLocationMap,
      "destination": destLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destAddress": destLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInfoMap);

    tripRideRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }
      //Car Details
      if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails =
              (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }

//Driver Name
      if ((eventSnap.snapshot.value as Map)["name"] != null) {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["name"].toString();
        });
      }

//Driver Phone Number
      if ((eventSnap.snapshot.value as Map)["phone"] != null) {
        setState(() {
          driverPhoneNo = (eventSnap.snapshot.value as Map)["phone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        userRideRequestStatus =
            (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if ((eventSnap.snapshot.value as Map)["DriverLocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["DriverLocation"]["latitude"]
                .toString());
        double driverCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["DriverLocation"]["longitude"]
                .toString());

        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status=accepted

        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
        }

        //status=arrived

        if (userRideRequestStatus == "arrived") {
          setState(() {
            driverRideStatus = "Driver has Arrived";
          });
        }

        //status=ontrip

        if (userRideRequestStatus == "ontrip") {
          updateReachingTimeToUserDropoffLocation(driverCurrentPositionLatLng);
        }

        //status=ended

        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext c) => PayFareAmountDialog(
                fareAmount: fareAmount,
              ),
            );

            if (response == "cashPayed") {
              //user can rate the driver now

              if ((eventSnap.snapshot.value as Map)["DriverId"] != null) {
                String assignedDriverId =
                    (eventSnap.snapshot.value as Map)["DriverId"].toString();

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => RateDriverScreen(
                              assignedDriverId: assignedDriverId,
                            )));

                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineAvailableDriversList = GeoFireAssistant.activeNearbyDriversList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickupPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickupPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus =
            "Driver is Coming ::${directionDetailsInfo.duration_text}";
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropoffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus =
            "Going towards Destination ::${directionDetailsInfo.duration_text}";
      });
      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers() async {
    // no active drivers available

    if (onlineAvailableDriversList.isEmpty == 0) {
      //cancel the ride request
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(
          msg:
              "No Avaiable Driver. Please wait and try again.App Restarting Now.");

      Future.delayed(const Duration(milliseconds: 4000), () {
        SystemNavigator.pop();
      });

      return;
    }
    await retrieveOnlineDriversInfo(onlineAvailableDriversList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectOnlineDriversScreen(
                referenceRideRequest: referenceRideRequest)));

    if (response == "DriverSelected") {
      FirebaseDatabase.instance
          .ref()
          .child("Drivers")
          .child(chosenDriverId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          //notify the driver about the ride request

          sendNotificationToDriver(chosenDriverId!);

          //display waiting Response ui from  Driver
          showWaitingResponseFromDriverUI();

          //Response from  Driver
          FirebaseDatabase.instance
              .ref()
              .child("Drivers")
              .child(chosenDriverId!)
              .child("newRideStatus")
              .onValue
              .listen((eventSnapshot) {
            //1. driver can cancel the rideRequest :: Push Notification

            //(newRideStatus = idle)

            if (eventSnapshot.snapshot.value == "idle") {
              Fluttertoast.showToast(
                  msg: "The driver has cancelled the request.");

              Future.delayed(const Duration(milliseconds: 3000), () {
                Fluttertoast.showToast(msg: "Restart App Now.");

                SystemNavigator.pop();
              });
            }

            //2.  driver has accept the rideRequest :: Push Notification

            //(newRideStatus = accepted)
            if (eventSnapshot.snapshot.value == "accepted") {
              //design and display ui for incoming driver
              showUIForAssignedDriverInfo();
            }
          });
        } else {
          Fluttertoast.showToast(msg: "This driver is not available.Try again");
        }
      });
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriver(String chosenDriverId) {
    //assign ridereuest id to newRideStatus for the selected driver in DB
    FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //automate the push notification
    FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("token")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send notifications now
        AssistantMethods.sendNotificationToDriverNow(
          deviceRegistrationToken,
          referenceRideRequest!.key.toString(),
          context,
        );

        Fluttertoast.showToast(msg: "Notification send Successfully.");
      } else {
        Fluttertoast.showToast(msg: "Please choose another driver.");
      }
    });
  }

  retrieveOnlineDriversInfo(List onlineAvailableDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("Drivers");
    for (int i = 0; i < onlineAvailableDriversList.length; i++) {
      await ref
          .child(onlineAvailableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverInfoKey = dataSnapshot.snapshot.value;
        dList.add(driverInfoKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyDriverIcon();

    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 350,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: MyDrawer(
            name: userName,
            phone: userPhoneNo,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newgoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 240;
              });

              locateUserPosition();
            },
          ),

          //custom hamburger button
          Positioned(
            top: 30,
            left: 18,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                } else {
                  //App will restart or refresh  automatically
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const MainScreen()));
                }
              },
              child: CircleAvatar(
                backgroundColor: const Color(0xff7D0E1F),
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          //UI for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(
                milliseconds: 120,
              ),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //for current location

                      Row(
                        children: [
                          const Icon(Icons.add_location_outlined,
                              color: Color(0xff7D0E1F)),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context)
                                            .userPickupLocation !=
                                        null
                                    ? "${(Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0, 30)}..."
                                    : " Can't Locate Address",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      //Drop Off Location
                      GestureDetector(
                        onTap: () async {
                          //go to search places

                          var responseFromSearchScreen = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const SearchPlacesScreen()));

                          if (responseFromSearchScreen == "ObatinedDropOff") {
                            //draw routes - draw polylines

                            await drawPolylineFromOrigintoDest();

                            setState(() {
                              openNavigationDrawer = false;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_outlined,
                                color: Color(0xff7D0E1F)),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? "${(Provider.of<AppInfo>(context).userDropOffLocation!.locationName!).substring(0, 20)}...."
                                      : "Your Drop Off Location ",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        onPressed: () {
                          if (Provider.of<AppInfo>(context, listen: false)
                                  .userDropOffLocation !=
                              null) {
                            saveRideRequestInfo();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select destination location ");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7D0E1F),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text(
                          "Request a Ride",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //UI for waiitng response from driver
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'Waiting for Response from Driver',
                          duration: const Duration(seconds: 6),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        ScaleAnimatedText(
                          'Please Wait...',
                          duration: const Duration(seconds: 10),
                          textStyle: const TextStyle(
                              fontSize: 32.0,
                              color: Colors.white,
                              fontFamily: 'Canterbury'),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

          //ui for display driver information
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration: const BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of ride
                    Center(
                      child: Text(
                        driverRideStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white54,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //driver vehicle details
                    Text(
                      driverCarDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 2.0,
                    ),

                    //driver name

                    Text(
                      driverName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white54,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //call driver button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(
                          Icons.phone_android,
                          color: Colors.black54,
                          size: 22,
                        ),
                        label: const Text(
                          "Call Driver",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> drawPolylineFromOrigintoDest() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);

    var destLatLng = LatLng(
        destPosition!.locationLatitude!, destPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points =");

    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResultList) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.redAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 3,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destLatLng.latitude &&
        originLatLng.longitude > destLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destLatLng.longitude),
          northeast: LatLng(destLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destLatLng);
    }

    newgoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker destMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow:
          InfoWindow(title: destPosition.locationName, snippet: "Destination"),
      position: destLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.redAccent,
      radius: 8,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.redAccent,
      radius: 8,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destLatLng,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //when any driver becomes active

          case Geofire.onKeyEntered:
            ActiveNearbyDrivers activeNearbyDrivers = ActiveNearbyDrivers();
            activeNearbyDrivers.locationLatitude = map['latitude'];
            activeNearbyDrivers.locationLongitude = map['longitude'];
            activeNearbyDrivers.driverId = map['key'];
            GeoFireAssistant.activeNearbyDriversList.add(activeNearbyDrivers);

            if (activeNearbyDriversKeysLoaded == true) {
              displayActiveDriversOnMap();
            }
            break;

          //when a driver goes offline

          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnMap();
            break;

          // when drivers moves update location
          case Geofire.onKeyMoved:
            ActiveNearbyDrivers activeNearbyDrivers = ActiveNearbyDrivers();
            activeNearbyDrivers.locationLatitude = map['latitude'];
            activeNearbyDrivers.locationLongitude = map['longitude'];
            activeNearbyDrivers.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyDriversLocation(
                activeNearbyDrivers);
            displayActiveDriversOnMap();
            break;

          //display the online drivers
          case Geofire.onGeoQueryReady:
            activeNearbyDriversKeysLoaded = true;
            displayActiveDriversOnMap();
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = <Marker>{};
      for (ActiveNearbyDrivers eachDriver
          in GeoFireAssistant.activeNearbyDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );
        driversMarkerSet.add(marker);
        setState(() {
          markerSet = driversMarkerSet;
        });
      }
    });
  }

  createActiveNearbyDriverIcon() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/ambulance_icon.jpeg")
          .then((value) {
        activeNearbyIcon = value;
      });
    }



 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Database',
      home: PatientListScreen(),
    );
  }
}

  }

