import 'package:flutter/material.dart';
import 'package:userapp/mainScreen/main_Screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          //image

          Container(
            width: 700,
            height: 370,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              "images/logo2.png",
              height: 600,
              width: 300,
            ),
          ),

          const SizedBox(
            height: 2,
          ),
          Column(
            children: [
              //company name
              const Text(
                "HealthCare Emergency System",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 50,
              ),

              //about you & your company - write some info
              const Text(
                "To break through the barrier between patients, ambulances, and hospitals, this app was created. "
                "\nBy locating and contacting the  ambulances, patients can get to hospitals on time."
                "\nOur main goal is to safeguard the patient's life while also saving them money and time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              //close
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MainScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7D0E1F),
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
