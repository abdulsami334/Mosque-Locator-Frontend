// import 'package:flutter/material.dart';
// import 'package:mosque_locator/models/mosque_model.dart';
// import 'package:mosque_locator/utils/app_styles.dart';
// import 'package:mosque_locator/views/map_view.dart';

// class MosqueDetailView extends StatelessWidget {
//   final MosqueModel mosque;

//   const MosqueDetailView({super.key, required this.mosque});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppStyles.primaryGreen,
     
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Photos Slider
//             // SizedBox(
//             //   height: 200,
//             //   child: PageView.builder(
//             //     itemCount: mosque.photos.isNotEmpty ? mosque.photos.length : 1,
//             //     itemBuilder: (context, index) {
//             //       final imageUrl = mosque.photos.isNotEmpty
//             //           ? mosque.photos[index]
//             //           : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7iXwQma6aLN5zScygf15nHkrGzMFKszpqIw&s';
//             //       return Image.network(imageUrl, fit: BoxFit.cover);
//             //     },
//             //   ),
//             // ),

//             // Mosque Info


//             Padding(
//               padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back, size: 30,color: Colors.white,)),
//                       const SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [Text("Asar", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
//                         Text("1 hr 44 mins until Asar", style: TextStyle(color: Colors.white, fontSize: 15),)],
//                       )
//                     ],
//                   ),
//                   Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             mosque.name,
//                             style: const TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on, color: Colors.green),
//                               const SizedBox(width: 6),
//                               Expanded(
//                                 child: Text(
//                                   mosque.address,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Text("${mosque.city}, ${mosque.area}",
//                               style: const TextStyle(color: Colors.grey)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Prayer Timings
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       const Text("Today's Prayer Timings",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600)),
//                       const Divider(),
//                       ...mosque.prayerTimes.entries.map((entry) {
//                         return prayerRow(entry.key, entry.value);
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Amenities
//             if (mosque.amenities.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Amenities",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.w600)),
//                         const Divider(),
//                         Wrap(
//                           spacing: 12,
//                           children: mosque.amenities.entries
//                               .where((a) => a.value == true)
//                               .map((a) => Chip(
//                                     label: Text(a.key),
//                                     avatar: const Icon(Icons.check_circle,
//                                         color: Colors.green),
//                                   ))
//                               .toList(),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Icons.directions),
//         label: const Text("Show Route"),
//         onPressed: () {
       
//           Navigator.pop(context, mosque);
//         },
//       ),
//     );
//   }

//   Widget prayerRow(String prayer, String time) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(prayer, style: const TextStyle(fontSize: 16)),
//           Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/utils/app_assets.dart';
import 'package:mosque_locator/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MosqueDetailView extends StatefulWidget {
  final MosqueModel mosque;

  const MosqueDetailView({super.key, required this.mosque});

  @override
  State<MosqueDetailView> createState() => _MosqueDetailViewState();
}

class _MosqueDetailViewState extends State<MosqueDetailView> {
  late List<MapEntry<String, String>> prayers;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ✅ Normalize timings (ensure AM/PM always present)
    prayers = widget.mosque.prayerTimes.entries.map((entry) {
      String fixedTime = fixTime(entry.key, entry.value.toString());
      return MapEntry(entry.key, fixedTime);
    }).toList();

    // ✅ Find upcoming prayer
    _currentIndex = getUpcomingPrayerIndex();

    // ✅ Auto refresh every 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// ✅ Ensure AM/PM is added
  String fixTime(String prayer, String time) {
    if (time.toLowerCase().contains("am") || time.toLowerCase().contains("pm")) {
      return time;
    }

    switch (prayer.toLowerCase()) {
      case "fajr":
        return "$time AM";
      case "dhuhr":
      case "asr":
      case "maghrib":
      case "isha":
        return "$time PM";
      default:
        return "$time AM"; // fallback
    }
  }

  int getUpcomingPrayerIndex() {
    final now = DateTime.now();
    for (int i = 0; i < prayers.length; i++) {
      try {
        final time = DateFormat("hh:mm a").parse(prayers[i].value);
        final todayPrayer = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        if (todayPrayer.isAfter(now)) return i;
      } catch (e) {
        debugPrint("Parse error: ${prayers[i].value}");
      }
    }
    return prayers.length - 1;
  }

  String getRemainingTime(String time) {
    try {
      final now = DateTime.now();
      final parsed = DateFormat("hh:mm a").parse(time);
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsed.hour,
        parsed.minute,
      );

      final diff = prayerTime.difference(now);
      if (diff.isNegative) return "Passed";

      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return "${hours > 0 ? "$hours hr " : ""}$minutes min left";
    } catch (e) {
      return "Invalid time";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = prayers[_currentIndex];

    return Scaffold(
      backgroundColor: AppStyles.primaryGreen,
      body: Column(
        children: [
          const SizedBox(height: 40),

          // 🔹 Header with arrow + current prayer info
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back,
                    size: 28, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      currentPrayer.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getRemainingTime(currentPrayer.value),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 🔹 Mosque Info Card
         

          // 🔹 Prayer Timings as vertical slider
         SizedBox(
  height: 120, // 👈 yahan apni marzi ki height set karein
  child: PageView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: prayers.length,
    controller: PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.4,
    ),
    onPageChanged: (index) {
      setState(() {
        _currentIndex = index;
      });
    },
    itemBuilder: (context, index) {
      final prayer = prayers[index];
      final isActive = index == _currentIndex;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [const BoxShadow(color: Colors.black26, blurRadius: 6)]
              : [],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prayer.key,
                style: TextStyle(
                  fontSize: isActive ? 16 : 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppStyles.primaryGreen : Colors.white,
                ),
              ),Image.asset(AppAssets.sunlogo, height: 10,),
              const SizedBox(height: 6),
              Text(
                prayer.value,
                style: TextStyle(
                  fontSize: isActive ? 16 : 8,
                  color: isActive ? AppStyles.primaryGreen : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
)
,
 Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mosque.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.mosque.address,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.mosque.city}, ${widget.mosque.area}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 🔹 Amenities
          if (widget.mosque.amenities.isNotEmpty)
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
                      const Text(
                        "Amenities",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 12,
                        children: widget.mosque.amenities.entries
                            .where((a) => a.value == true)
                            .map(
                              (a) => Chip(
                                label: Text(a.key),
                                avatar: const Icon(Icons.check_circle,
                                    color: Colors.green),
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 60),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.directions),
        label: const Text("Show Route"),
        onPressed: () {
          Navigator.pop(context, widget.mosque);
        },
      ),
    );
  }
}
