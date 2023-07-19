import 'package:flutter/material.dart';
import 'package:userapp/mainScreen/about_screen.dart';
import 'package:userapp/mainScreen/profile_screen.dart';
import 'package:userapp/mainScreen/trips_history_screen.dart';
import 'package:userapp/splashScreen/splash_screen.dart';

import '../global/global.dart';

class MyDrawer extends StatefulWidget {
  String? name;
  String? phone;

  MyDrawer({super.key, this.name, this.phone});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        SizedBox(
          height: 150,
          child: DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xff7D0E1F),
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.phone.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const TripsHistoryScreen()));
          },
          child: const ListTile(
            leading: Icon(Icons.history, color: Color(0xff7D0E1F)),
            title: Text("History",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const ProfileScreen()));
          },
          child: const ListTile(
            leading: Icon(Icons.person, color: Color(0xff7D0E1F)),
            title: Text("Visit Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                )),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const AboutScreen()));
          },
          child: const ListTile(
            leading: Icon(Icons.info, color: Color(0xff7D0E1F)),
            title: Text("About",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                )),
          ),
        ),
        const SizedBox(
          height: 400,
        ),
        GestureDetector(
          onTap: () {
            fAuth.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const MySplashScreen()));
          },
          child: const ListTile(
            leading: Icon(Icons.logout, color: Color(0xff7D0E1F)),
            title: Text("Sign Out",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ),
      ],
    ));
  }
}
