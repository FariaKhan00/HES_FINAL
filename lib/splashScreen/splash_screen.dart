import 'dart:async';

import 'package:flutter/material.dart';
import 'package:userapp/authentication/login_screen.dart';
import 'package:userapp/mainScreen/main_Screen.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;

    Timer(const Duration(seconds: 3), () async {
      if (fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo2.png"),
              const SizedBox(
                height: 6,
              ),
              // const Text(
              //   "HealthCare Emergency System",
              //   style: TextStyle(
              //       fontSize: 26,
              //       color: Color(0xff7D0E1F),
              //       fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
