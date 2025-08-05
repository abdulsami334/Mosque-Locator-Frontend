import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? mapController;
  LatLng? currentPosition;

  final List<Marker>_mosqueMarkers=[
    Marker(markerId: MarkerId("mosque1"),
      position: LatLng(24.8607, 67.0011),
      infoWindow: InfoWindow(title: "Jamia Masjid Noor"),
    ),
    
  ];
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  Future<void>  _getCurrentLocation()async{
    Position position=await Geolocator.getCurrentPosition(
 desiredAccuracy: LocationAccuracy.high
    );
     setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
         appBar: AppBar(title: const Text("Nearby Mosques")),
         body: currentPosition==null ? const Center(child: CircularProgressIndicator()):
         GoogleMap(
          onMapCreated:(controller){
            mapController = controller;
          } ,
            initialCameraPosition: CameraPosition(
                target: currentPosition!,
                zoom: 14,
              ),
           myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.from(_mosqueMarkers),
          
         ),
    );
  }
}