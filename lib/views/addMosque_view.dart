import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/providers/mosque_provider.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:mosque_locator/views/map_view.dart';
import 'package:provider/provider.dart';

class AddMosqueView extends StatefulWidget {
  final MosqueModel? mosque;
  const AddMosqueView({Key? key, this.mosque}):super(key: key);

  @override
  State<AddMosqueView> createState() => _AddMosqueViewState();
}

class _AddMosqueViewState extends State<AddMosqueView> {
  final _formKey    = GlobalKey<FormState>();
  final nameCtrl    = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl    = TextEditingController();
  final areaCtrl    = TextEditingController();
  final locCtrl     = TextEditingController();

  final fajrCtrl    = TextEditingController();
  final dhuhrCtrl   = TextEditingController();
  final asrCtrl     = TextEditingController();
  final maghribCtrl = TextEditingController();
  final ishaCtrl    = TextEditingController();


bool hasParking = false;
bool hasWomenSection = false;
bool hasWheelchair = false;
bool hasAC = false;
bool hasWashroom = false;
  double? lat;
  double? lng;
  bool isLoading = false;


// @override
//  void initState(){
//   super.initState();
//   if(widget.mosque!=null)
//   {
//     nameCtrl=widget.mosque!.name;
//   }
//  }

  /* ---------- Pick & Reverse-Geocode Location ---------- */
  Future<void> _pickLocation() async {
    final service = await Geolocator.isLocationServiceEnabled();
    if (!service) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final picked = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MosqueView(
          isPickerMode: true,
          initialPos: LatLng(pos.latitude, pos.longitude),
        ),
      ),
    );
    if (picked == null) return;

    final placemarks = await placemarkFromCoordinates(
        picked.latitude, picked.longitude);
    final place = placemarks.first;
    final address =
        '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .trim();

    setState(() {
      lat = picked.latitude;
      lng = picked.longitude;
      locCtrl.text = address;
    });
  }

  /* ---------- Save Mosque ---------- */
Future<void> _saveMosque(BuildContext context) async {
  if (!_formKey.currentState!.validate()) return;
  if (lat == null || lng == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please pick a location first'),
        backgroundColor: Colors.red.shade300,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() => isLoading = true);
  final provider = Provider.of<MosqueProvider>(context, listen: false);

  final ok = widget.mosque == null
      ? await provider.addMosque(
          name: nameCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          city: cityCtrl.text.trim(),
          area: areaCtrl.text.trim(),
          lat: lat!,
          lng: lng!,
          fajr: fajrCtrl.text.trim(),
          dhuhr: dhuhrCtrl.text.trim(),
          asr: asrCtrl.text.trim(),
          maghrib: maghribCtrl.text.trim(),
          isha: ishaCtrl.text.trim(),
          amenities: {
            "parking": hasParking,
            "womenSection": hasWomenSection,
            "wheelchairAccess": hasWheelchair,
            "ac": hasAC,
            "washroom": hasWashroom,
          },
        )
      : await provider.updateMosque(
  widget.mosque!.id,
  {
    "name": nameCtrl.text.trim(),
    "address": addressCtrl.text.trim(),
    "city": cityCtrl.text.trim(),
    "area": areaCtrl.text.trim(),
    "coordinates": {
      "lat": lat,
      "lng": lng,
    },
    "prayerTimes": {
      "fajr": fajrCtrl.text.trim(),
      "dhuhr": dhuhrCtrl.text.trim(),
      "asr": asrCtrl.text.trim(),
      "maghrib": maghribCtrl.text.trim(),
      "isha": ishaCtrl.text.trim(),
    },
    "amenities": {
      "parking": hasParking,
      "womenSection": hasWomenSection,
      "wheelchairAccess": hasWheelchair,
      "ac": hasAC,
      "washroom": hasWashroom,
    },
  },
);// ✅ Semicolon lagaya

  setState(() => isLoading = false);

  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.mosque == null ? 'Save' : 'Update'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? '❌ Failed'),
        backgroundColor: Colors.red.shade300,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
 @override
void initState() {
  super.initState();
  if (widget.mosque != null) {
    final m = widget.mosque!;
    nameCtrl.text = m.name;
    addressCtrl.text = m.address;
    cityCtrl.text = m.city;
    areaCtrl.text = m.area;

    // ✅ Fix: assign lat/lng correctly
    lat = m.coordinates.lat;
    lng = m.coordinates.lng;

    locCtrl.text = "${m.address}, ${m.city}";

    // ✅ Fix: access prayerTimes correctly
    fajrCtrl.text = m.prayerTimes['fajr'] ?? '';
    dhuhrCtrl.text = m.prayerTimes['dhuhr'] ?? '';
    asrCtrl.text = m.prayerTimes['asr'] ?? '';
    maghribCtrl.text = m.prayerTimes['maghrib'] ?? '';
    ishaCtrl.text = m.prayerTimes['isha'] ?? '';

    // ✅ Amenities
    hasParking = m.amenities['parking'] ?? false;
    hasWomenSection = m.amenities['womenSection'] ?? false;
    hasWheelchair = m.amenities['wheelchairAccess'] ?? false;
    hasAC = m.amenities['ac'] ?? false;
    hasWashroom = m.amenities['washroom'] ?? false;
  }
}
  /* ---------- Build ---------- */
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
         title: Text(widget.mosque == null ? 'Add Mosque' : 'Edit Mosque'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppStyles.primaryGreen,
        foregroundColor: Colors.white,
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors:Appstyle.primarycolor,
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildInput(nameCtrl, 'Mosque Name', Icons.mosque),
                _buildInput(addressCtrl, 'Address', Icons.home),
                _buildInput(cityCtrl, 'City', Icons.location_city),
                _buildInput(areaCtrl, 'Area', Icons.map),
                const SizedBox(height: 12),
        
                /* Location Card */
                GestureDetector(
                  onTap: isLoading ? null : _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF0A9C8C)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            locCtrl.text.isEmpty ? 'Tap to pick location' : locCtrl.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: locCtrl.text.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                if (lat != null) const SizedBox(height: 8),
        
                const SizedBox(height: 24),
                const Text(
                  '🕌 Namaz Timings',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF0A7E8C),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimeInput(fajrCtrl, 'Fajr'),
                _buildTimeInput(dhuhrCtrl, 'Dhuhr'),
                _buildTimeInput(asrCtrl, 'Asr'),
                _buildTimeInput(maghribCtrl, 'Maghrib'),
                _buildTimeInput(ishaCtrl, 'Isha'),
        
                const SizedBox(height: 36),
                const SizedBox(height: 24),
        const Text(
          '🏷️ Amenities',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF0A7E8C),
          ),
        ),
        const SizedBox(height: 12),
        
        SwitchListTile(
          value: hasParking,
          onChanged: (val) => setState(() => hasParking = val),
          title: const Text("Parking Available"),
        ),
        SwitchListTile(
          value: hasWomenSection,
          onChanged: (val) => setState(() => hasWomenSection = val),
          title: const Text("Women's Section"),
        ),
        SwitchListTile(
          value: hasWheelchair,
          onChanged: (val) => setState(() => hasWheelchair = val),
          title: const Text("Wheelchair Access"),
        ),
        SwitchListTile(
          value: hasAC,
          onChanged: (val) => setState(() => hasAC = val),
          title: const Text("Air Conditioning"),
        ),
        SwitchListTile(
          value: hasWashroom,
          onChanged: (val) => setState(() => hasWashroom = val),
          title: const Text("Washroom"),
        ),
        
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A9C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 4,
                    ),
                    onPressed: (isLoading || lat == null)
                        ? null
                        : () => _saveMosque(context),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Text(
                             widget.mosque == null ? ' Mosque added' : ' Mosque updated',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0A9C8C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0A9C8C)),
          ),
        ),
        validator: (val) => val!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time, color: Color(0xFF0A9C8C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (val) => val!.isEmpty ? 'Required' : null,
      ),
    );
  }
}