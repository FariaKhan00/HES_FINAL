import 'package:flutter/material.dart';
import 'package:userapp/global/global.dart';
import 'package:userapp/mainScreen/main_Screen.dart';
import 'package:userapp/widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //name
            Text(
              userModelCurrentInfo!.name!,
              style: const TextStyle(
                fontSize: 50.0,
                color: Color(0xff7D0E1F),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Color(0xff7D0E1F),
                height: 2,
                thickness: 2,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),

            //Phone
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.email!,
              iconData: Icons.email,
            ),

            const SizedBox(
              height: 20,
            ),

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
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
