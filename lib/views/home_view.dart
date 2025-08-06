import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosque_locator/models/mosque_model.dart';

import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/services/DirectionService.dart';
import 'package:mosque_locator/views/mosque_detail_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Polyline> _polylines = {};

  // TODO: Move to .env or secrets file
  final String _googleApiKey = 'AIzaSyCIPFCI9wnhaF6tSeoe-uCdjVBO7sidJnw';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<MosqueProvider>(context, listen: false).loadMosques(),
    );
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() => currentPosition = LatLng(position.latitude, position.longitude));
  }

  Future<void> _getRouteToMosque(LatLng mosqueLatLng) async {
    if (currentPosition == null) return;

    try {
      final points = await DirectionService().getRouteCoordinates(
        currentPosition!,
        mosqueLatLng,
        _googleApiKey,
      );

      if (!mounted) return;
      if (points.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found')),
        );
        return;
      }

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: points,
          ),
        );
      });
    } catch (e) {
      debugPrint('Route error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = Provider.of<MosqueProvider>(context);

    final mosqueMarkers = {
      for (final mosque in mosqueProvider.mosques)
        Marker(
          markerId: MarkerId(mosque.id),
          position: LatLng(mosque.latitude, mosque.longitude),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet: mosque.address,
          ),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Mosques')),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) => mapController = c,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: mosqueMarkers,
                  polylines: _polylines,
                ),
                // --- Horizontal mosque cards ---
                Positioned(
                  bottom: 16,
                  left: 8,
                  right: 8,
                  child: SizedBox(
                    height: 120,
                    child: mosqueProvider.mosques.isEmpty
                        ? const Center(child: Text('No masjids found'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mosqueProvider.mosques.length,
                            itemBuilder: (context, index) {
                              final mosque = mosqueProvider.mosques[index];
                              final distanceInMeters =
                                  (currentPosition != null)
                                      ? Geolocator.distanceBetween(
                                          currentPosition!.latitude,
                                          currentPosition!.longitude,
                                          mosque.latitude,
                                          mosque.longitude,
                                        )
                                      : 0.0;
                              final distanceInKm =
                                  (distanceInMeters / 1000).toStringAsFixed(1);

                              return GestureDetector(
  onTap: () async {
    // 1. Open detail screen
    final selectedMosque = await Navigator.push<MosqueModel>(
      context,
      MaterialPageRoute(
        builder: (_) => MosqueDetailView(mosque: mosque),
      ),
    );

    // 2. If user pressed "Show Route", draw the route
    if (selectedMosque != null && context.mounted) {
      final mosqueLatLng = LatLng(selectedMosque.latitude, selectedMosque.longitude);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(mosqueLatLng, 16),
      );
      _getRouteToMosque(mosqueLatLng);
    }
  },
  child: Container(
    width: 180,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mosque.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '$distanceInKm km away',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  ),
);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}