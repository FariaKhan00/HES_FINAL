import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:userapp/assistants/assistant_methods.dart';
import 'package:userapp/global/global.dart';
import 'package:userapp/mainScreen/main_Screen.dart';

class SelectOnlineDriversScreen extends StatefulWidget {
  DatabaseReference? referenceRideRequest;

  SelectOnlineDriversScreen({super.key, this.referenceRideRequest});

  @override
  _SelectOnlineDriversScreenState createState() =>
      _SelectOnlineDriversScreenState();
}

class _SelectOnlineDriversScreenState extends State<SelectOnlineDriversScreen> {
  String fareAmount = "";

  getFareAmountByVehicleType(int index) {
    if (tripDirectionDetailsInfo != null) {
      if (dList[index]["car_details"]["type"].toString() ==
          "Paramedic") // For Equipped Ambualnces with Paramedics
      {
        fareAmount = (AssistantMethods.calculateFareAmountOriginToDest(
                    tripDirectionDetailsInfo!) *
                2)
            .toStringAsFixed(1);
      }
      if (dList[index]["car_details"]["type"].toString() ==
          "Non-Paramedic") //For Non-Eqipped Ambualnces with no paramedics
      {
        fareAmount = (AssistantMethods.calculateFareAmountOriginToDest(
                tripDirectionDetailsInfo!))
            .toString();
      }

      return fareAmount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Nearest Online Drivers",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.red,
          ),
          onPressed: () {
            //delete the ride request from database

            widget.referenceRideRequest!.remove();
            Fluttertoast.showToast(msg: "You Have Cancelled the Ride Request.");
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const MainScreen()));
          },
        ),
      ),
      body: ListView.builder(
        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                chosenDriverId = dList[index]["id"].toString();
              });

              Navigator.pop(context, "DriverSelected");
            },
            child: Card(
              color: Colors.black45,
              elevation: 3,
              shadowColor: Colors.redAccent,
              margin: const EdgeInsets.all(0),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset(
                    "images/${dList[index]["car_details"]["type"]}.jpg",
                    width: 70,
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      dList[index]["name"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      dList[index]["car_details"]["type"],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    SmoothStarRating(
                      rating: dList[index]["ratings"] == null
                          ? 0.0
                          : double.parse(dList[index]["ratings"]),
                      color: Colors.black,
                      borderColor: Colors.black,
                      allowHalfRating: true,
                      starCount: 5,
                      size: 15,
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rs" + getFareAmountByVehicleType(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      tripDirectionDetailsInfo != null
                          ? tripDirectionDetailsInfo!.duration_text!
                          : "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      tripDirectionDetailsInfo != null
                          ? tripDirectionDetailsInfo!.distance_text!
                          : "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
