import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/infoHandler/app_info.dart';
import 'package:userapp/mainScreen/main_Screen.dart';
import 'package:userapp/widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff7D0E1F),
        title: const Text("Trips History"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const MainScreen()));
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i) => const Divider(
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i) {
          return Card(
            color: Colors.black,
            child: HistoryDesignUIWidget(
              tripHistoryModel: Provider.of<AppInfo>(context, listen: false)
                  .allTripsHistoryInformationList[i],
            ),
          );
        },
        itemCount: Provider.of<AppInfo>(context, listen: false)
            .allTripsHistoryInformationList
            .length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
