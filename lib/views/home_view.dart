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
  final String _apiKey = 'AIzaSyCIPFCI9wnhaF6tSeoe-uCdjVBO7sidJnw';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;

    setState(() => currentPosition = LatLng(pos.latitude, pos.longitude));

    Provider.of<MosqueProvider>(context, listen: false)
        .loadNearbyMosques(pos.latitude, pos.longitude, radius: 5000);
  }

  Future<void> _drawRoute(LatLng dest) async {
    if (currentPosition == null) return;
    try {
      final points = await DirectionService()
          .getRouteCoordinates(currentPosition!, dest, _apiKey);
      if (!mounted) return;
      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MosqueProvider>(context);
    final markers = provider.mosques
        .map((m) => Marker(
              markerId: MarkerId(m.id),
              position: LatLng(m.coordinates.lat, m.coordinates.lng),
              infoWindow: InfoWindow(title: m.name, snippet: m.address),
            ))
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Mosques')),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) => mapController = c,
                  initialCameraPosition:
                      CameraPosition(target: currentPosition!, zoom: 14),
                  myLocationEnabled: true,
                  markers: markers,
                  polylines: _polylines,
                ),
                Positioned(
                  bottom: 16,
                  left: 8,
                  right: 8,
                  child: SizedBox(
                    height: 120,
                    child: provider.mosques.isEmpty
                        ? const Center(child: Text('No mosques found'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.mosques.length,
                            itemBuilder: (_, i) {
                              final m = provider.mosques[i];
                              final distanceMeters =
                                  Geolocator.distanceBetween(
                                currentPosition!.latitude,
                                currentPosition!.longitude,
                                m.coordinates.lat,
                                m.coordinates.lng,
                              );

                              return GestureDetector(
                                onTap: () async {
                                  final res = await Navigator.push<MosqueModel>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MosqueDetailView(mosque: m),
                                    ),
                                  );
                                  if (res != null && context.mounted) {
                                    final latLng = LatLng(
                                      res.coordinates.lat,
                                      res.coordinates.lng,
                                    );
                                    mapController?.animateCamera(
                                      CameraUpdate.newLatLngZoom(latLng, 16),
                                    );
                                    _drawRoute(latLng);
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
                                        blurRadius: 6,
                                        color: Colors.black12,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${formatDistance(distanceMeters)} away',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
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
