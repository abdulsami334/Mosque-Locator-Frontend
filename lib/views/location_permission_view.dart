import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/map_view.dart';
import 'package:mosque_locator/widgets/Navigation/main_navigation.dart';

class LocationPermissionView extends StatefulWidget {
  const LocationPermissionView({super.key});

  @override
  State<LocationPermissionView> createState() => _LocationPermissionViewState();
}

class _LocationPermissionViewState extends State<LocationPermissionView> {
  bool isLoading = false;

  Future<void> _requestLocationPermission()async{
setState(() {
  isLoading: true;
});
LocationPermission permission=await Geolocator.checkPermission();

 if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission==LocationPermission.always|| permission==LocationPermission.whileInUse){
      Position position=await Geolocator.getCurrentPosition(
 desiredAccuracy: LocationAccuracy.high,
      );
         Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }else{
      setState(() {
        isLoading:false;
      });

      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Location permission denied')));
    }

  


  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: AppStyles.background,
body: Center(
  child: isLoading? const CircularProgressIndicator(

  ):Column(
   mainAxisAlignment: MainAxisAlignment.center,
   crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        
        height: 150,
        width: 150,
        AppAssets.locationIcon),
       const SizedBox(height: 30),
         const Text(
                      "We need your location to show nearby mosques.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: 
                     _requestLocationPermission ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ), child: const Text("Allow location",  style: TextStyle(fontSize: 16, color: Colors.white), ))
    ],
    
  )
),

    );
  }
}