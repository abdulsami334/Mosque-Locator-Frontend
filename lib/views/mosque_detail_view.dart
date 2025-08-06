import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';

class MosqueDetailView extends StatelessWidget {
  final MosqueModel mosque;

  const MosqueDetailView({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mosque.name ?? 'Masjid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mosque.name ?? 'Masjid',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mosque.address ?? 'Address not available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Today's Prayer Timings:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text("🕓 Fajr: 5:00 AM"),
            const Text("🕓 Dhuhr: 1:30 PM"),
            const Text("🕓 Asr: 4:30 PM"),
            const Text("🕓 Maghrib: 6:45 PM"),
            const Text("🕓 Isha: 8:15 PM"),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text("Show Route"),
                onPressed: () {
                  // Return the mosque back so HomeView can draw the route
                  Navigator.pop(context, mosque);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}