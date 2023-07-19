import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/global/global.dart';
import 'package:userapp/global/map_key.dart';
import 'package:userapp/infoHandler/app_info.dart';
import 'package:userapp/models/directions.dart';
import 'package:userapp/models/predicted_places.dart';
import 'package:userapp/widgets/progress_dialog.dart';

import '../assistants/request_assistant.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting Up Drop-Off, Please Wait..",
      ),
    );
    String placeDirectionDetails =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi =
        await RequestAssistant.recieveRequest(placeDirectionDetails);

    Navigator.pop(context);

    if (responseApi == "Error occured,No Response.") {
      return;
    }
    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "ObatinedDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlaces!.placeid!, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(60, 119, 119, 119),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              const Icon(
                Icons.add_location,
                color: Color(0xff7D0E1F),
              ),
              const SizedBox(
                width: 14.0,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    widget.predictedPlaces!.maintext!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    widget.predictedPlaces!.secondarytext!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ))
            ],
          ),
        ));
  }
}
