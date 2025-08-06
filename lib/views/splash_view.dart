import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/location_permission_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 10),(){
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationPermissionView()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppStyles.primaryGreen,
       body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Image.asset(AppAssets.logo, height: 100),
                const SizedBox(height: 20),
                Text(
                "Mosque Locator",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),)
          ],
         ),
       ),
    );
  }
}