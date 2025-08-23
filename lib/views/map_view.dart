// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:mosque_locator/models/mosque_model.dart';
// import 'package:mosque_locator/providers/mosque_provider.dart';
// import 'package:mosque_locator/services/DirectionService.dart';
// import 'package:mosque_locator/views/mosque_detail_view.dart';
// import 'package:provider/provider.dart';

// class MosqueView extends StatefulWidget {
//   final bool isPickerMode;
//   final LatLng? initialPos;
//   const MosqueView({super.key, this.isPickerMode = false, this.initialPos});

//   @override
//   State<MosqueView> createState() => _MosqueViewState();
// }

// class _MosqueViewState extends State<MosqueView> {
//   GoogleMapController? mapController;
//   LatLng? currentPosition;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   final String _apiKey = 'AIzaSyCIPFCI9wnhaF6tSeoe-uCdjVBO7sidJnw';

//   @override
//   void initState() {
//     super.initState();
//     _initLocation();
//   }

//   Future<void> _initLocation() async {
//     if (widget.initialPos != null) {
//       setState(() => currentPosition = widget.initialPos);
//       _updateMarker(currentPosition!);
//       return;
//     }

//     final service = await Geolocator.isLocationServiceEnabled();
//     if (!service) return;

//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever) return;

//     final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     if (!mounted) return;

//     setState(() => currentPosition = LatLng(pos.latitude, pos.longitude));
//     _updateMarker(currentPosition!);

//     if (!widget.isPickerMode) {
//       Provider.of<MosqueProvider>(context, listen: false)
//           .loadNearbyMosques(pos.latitude, pos.longitude, radius: 5000);
//     }
//   }

//   void _updateMarker(LatLng pos) {
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('picked'),
//           position: pos,
//           draggable: widget.isPickerMode,
//           onDragEnd: (newPos) => setState(() => currentPosition = newPos),
//         ),
//       );
//     });
//   }

//   Future<void> _drawRoute(LatLng dest) async {
//     if (currentPosition == null || widget.isPickerMode) return;
//     try {
//       final points = await DirectionService()
//           .getRouteCoordinates(currentPosition!, dest, _apiKey);
//       if (!mounted) return;
//       setState(() {
//         _polylines.clear();
//         _polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           color: Colors.blue,
//           width: 5,
//           points: points,
//         ));
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     }
//   }

//   Future<String> _addressFromLatLng(LatLng pos) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//       final p = placemarks.first;
//       return '${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}'
//           .trim();
//     } catch (_) {
//       return 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
//     }
//   }

//   String formatDistance(double meters) {
//     return meters < 1000
//         ? '${meters.toStringAsFixed(0)} m'
//         : '${(meters / 1000).toStringAsFixed(1)} km';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<MosqueProvider>(context);

//     // Build proper Set<Marker>
//     final Set<Marker> markers = widget.isPickerMode
//         ? _markers
//         : provider.mosques
//             .map<Marker>(
//               (m) => Marker(
//                 markerId: MarkerId(m.id),
//                 position: LatLng(m.coordinates.lat, m.coordinates.lng),
//                 infoWindow: InfoWindow(title: m.name, snippet: m.address),
//               ),
//             )
//             .toSet();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.isPickerMode ? 'Pin the Location' : 'Nearby Mosques'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//         actions: widget.isPickerMode
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.check),
//                   onPressed: () async {
//                     final addr = await _addressFromLatLng(currentPosition!);
//                     Navigator.pop(context, currentPosition);
//                   },
//                 ),
//               ]
//             : null,
//       ),
//       body: currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (c) => mapController = c,
//               initialCameraPosition:
//                   CameraPosition(target: currentPosition!, zoom: 14),
//               myLocationEnabled: true,
//               markers: markers,
//               polylines: _polylines,
//               onTap: widget.isPickerMode
//                   ? (pos) {
//                       setState(() => currentPosition = pos);
//                       _updateMarker(pos);
//                     }
//                   : null,
//             ),
//       floatingActionButton: widget.isPickerMode
//           ? FloatingActionButton(
//               onPressed: () async {
//                 final addr = await _addressFromLatLng(currentPosition!);
//                 Navigator.pop(context, currentPosition);
//               },
//               child: const Icon(Icons.check),
//             )
//           : null,
//       bottomSheet: widget.isPickerMode
//           ? null
//           : provider.mosques.isEmpty
//               ? const SizedBox.shrink()
//               : SizedBox(
//                   height: 120,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: provider.mosques.length,
//                     itemBuilder: (_, i) {
//                       final m = provider.mosques[i];
//                       final distance = Geolocator.distanceBetween(
//                         currentPosition!.latitude,
//                         currentPosition!.longitude,
//                         m.coordinates.lat,
//                         m.coordinates.lng,
//                       );
//                       return GestureDetector(
//                         onTap: () async {
//                           final res = await Navigator.push<MosqueModel>(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => MosqueDetailView(mosque: m)),
//                           );
//                           if (res != null && mounted) {
//                             final latLng = LatLng(
//                                 res.coordinates.lat, res.coordinates.lng);
//                             mapController?.animateCamera(
//                                 CameraUpdate.newLatLngZoom(latLng, 16));
//                             _drawRoute(latLng);
//                           }
//                         },
//                         child: Container(
//                           width: 180,
//                           margin: const EdgeInsets.only(right: 12),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: const [
//                               BoxShadow(
//                                 blurRadius: 6,
//                                 color: Colors.black12,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(m.name,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold)),
//                               const SizedBox(height: 4),
//                               Text('${formatDistance(distance)} away',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
// lib/views/mosque_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/services/DirectionService.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/mosque_detail_view.dart';
import 'package:provider/provider.dart';

class MosqueView extends StatefulWidget {
  final bool isPickerMode;
  final LatLng? initialPos;

  const MosqueView({super.key, this.isPickerMode = false, this.initialPos});

  @override
  State<MosqueView> createState() => _MosqueViewState();
}

class _MosqueViewState extends State<MosqueView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final String _apiKey = 'AIzaSyCIPFCI9wnhaF6tSeoe-uCdjVBO7sidJnw';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialPos != null) {
      setState(() => currentPosition = widget.initialPos);
      _updateMarker(currentPosition!);
      return;
    }

    final service = await Geolocator.isLocationServiceEnabled();
    if (!service) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;

    setState(() => currentPosition = LatLng(pos.latitude, pos.longitude));
    _updateMarker(currentPosition!);

    if (!widget.isPickerMode) {
      // Ensure the provider finishes loading before first build
      await Provider.of<MosqueProvider>(context, listen: false)
          .loadNearbyMosques(pos.latitude, pos.longitude, radius: 5000);
    }
  }

  void _updateMarker(LatLng pos) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('picked'),
          position: pos,
          draggable: widget.isPickerMode,
          onDragEnd: (newPos) => setState(() => currentPosition = newPos),
        ),
      );
    });
  }

  Future<void> _drawRoute(LatLng dest) async {
    if (currentPosition == null || widget.isPickerMode) return;
    try {
      final points = await DirectionService()
          .getRouteCoordinates(currentPosition!, dest, _apiKey);
      if (!mounted) return;
      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blueAccent,
          width: 6,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          points: points,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> _addressFromLatLng(LatLng pos) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.first;
      return '${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}'
          .trim();
    } catch (_) {
      return 'Lat: ${pos.latitude.toStringAsFixed(4)}, '
          'Lng: ${pos.longitude.toStringAsFixed(4)}';
    }
  }

  String formatDistance(double meters) {
    return meters < 1000
        ? '${meters.toStringAsFixed(0)} m'
        : '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MosqueProvider>(context);

    final Set<Marker> markers = widget.isPickerMode
        ? _markers
        : provider.mosques
            .map<Marker>(
              (m) => Marker(
                markerId: MarkerId(m.id),
                position: LatLng(m.coordinates.lat, m.coordinates.lng),
                infoWindow: InfoWindow(title: m.name, snippet: m.address),
              ),
            )
            .toSet();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.isPickerMode ? 'Pin the Location' : 'Nearby Mosques'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppStyles.primaryGreen, AppStyles.primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: widget.isPickerMode
            ? [
                IconButton(
                  tooltip: 'Confirm',
                  icon: const Icon(Icons.check_circle, size: 28),
                  onPressed: () => Navigator.pop(context, currentPosition),
                )
              ]
            : null,
      ),
      body: currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0A9C8C),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) => mapController = c,
                  initialCameraPosition:
                      CameraPosition(target: currentPosition!, zoom: 14),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  markers: markers,
                  polylines: _polylines,
                  onTap: widget.isPickerMode
                      ? (pos) {
                          setState(() => currentPosition = pos);
                          _updateMarker(pos);
                        }
                      : null,
                ),
                if (widget.isPickerMode)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm Location'),
                        onPressed: () => Navigator.pop(context, currentPosition),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomSheet: widget.isPickerMode
          ? null
          : provider.mosques.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  height: 140,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.mosques.length,
                    itemBuilder: (_, i) {
                      final m = provider.mosques[i];
                      if (currentPosition == null) {
  return const SizedBox.shrink();
}
                      final distance = Geolocator.distanceBetween(
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
                              builder: (_) => MosqueDetailView(mosque: m),
                            ),
                          );
                          if (res != null && mounted) {
                            final latLng = LatLng(
                                res.coordinates.lat, res.coordinates.lng);
                            mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(latLng, 16),
                            );
                            _drawRoute(latLng);
                          }
                        },
                        child: Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0A7E8C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatDistance(distance)} away',
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
    );
  }
}