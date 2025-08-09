import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';

class MosqueDetailView extends StatelessWidget {
  final MosqueModel mosque;

  const MosqueDetailView({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(mosque.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photos Slider
            // SizedBox(
            //   height: 200,
            //   child: PageView.builder(
            //     itemCount: mosque.photos.isNotEmpty ? mosque.photos.length : 1,
            //     itemBuilder: (context, index) {
            //       final imageUrl = mosque.photos.isNotEmpty
            //           ? mosque.photos[index]
            //           : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7iXwQma6aLN5zScygf15nHkrGzMFKszpqIw&s';
            //       return Image.network(imageUrl, fit: BoxFit.cover);
            //     },
            //   ),
            // ),

            // Mosque Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              mosque.address,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("${mosque.city}, ${mosque.area}",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),

            // Prayer Timings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Today's Prayer Timings",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const Divider(),
                      ...mosque.prayerTimes.entries.map((entry) {
                        return prayerRow(entry.key, entry.value);
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            // Amenities
            if (mosque.amenities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Amenities",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const Divider(),
                        Wrap(
                          spacing: 12,
                          children: mosque.amenities.entries
                              .where((a) => a.value == true)
                              .map((a) => Chip(
                                    label: Text(a.key),
                                    avatar: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                  ))
                              .toList(),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.directions),
        label: const Text("Show Route"),
        onPressed: () {
          Navigator.pop(context, mosque);
        },
      ),
    );
  }

  Widget prayerRow(String prayer, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prayer, style: const TextStyle(fontSize: 16)),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
