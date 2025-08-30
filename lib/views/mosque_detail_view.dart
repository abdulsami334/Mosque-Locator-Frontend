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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    prayers = widget.mosque.prayerTimes.entries.map((entry) {
      String fixedTime = fixTime(entry.key, entry.value.toString());
      return MapEntry(entry.key, fixedTime);
    }).toList();

    _currentIndex = getUpcomingPrayerIndex();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.25,
    );

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _currentIndex = getUpcomingPrayerIndex();
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
        return "$time AM";
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppStyles.primaryGreen,
      body: Stack(
        children: [
          // Prayer Times Slider - Compact design
          Positioned(
            top: screenHeight * 0.18,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 110,
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: prayers.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final prayer = prayers[index];
                  final isActive = index == _currentIndex;
                  final isPassed = index < getUpcomingPrayerIndex();

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.white.withOpacity(0.25) 
                            : isPassed
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isActive 
                            ? Border.all(color: Colors.white, width: 1.2) 
                            : isPassed
                              ? Border.all(color: Colors.white.withOpacity(0.5), width: 0.8)
                              : Border.all(color: Colors.transparent, width: 0),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 80,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prayer.key,
                            style: TextStyle(
                              fontSize: isActive ? 13 : 10,
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.white70 : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Image.asset(
                            AppAssets.sunlogo, 
                            height: isActive ? 25 : 20,
                            color: isPassed ? Colors.white70 : Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prayer.value,
                            style: TextStyle(
                              fontSize: isActive ? 13 : 10,
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.white70 : Colors.white,
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

          // Main content card with curved top
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: screenHeight * 0.33,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mosque Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppStyles.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mosque,
                        size: 40,
                        color: AppStyles.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Mosque Name
                    Text(
                      widget.mosque.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Location with fixed icon - PROPERLY ALIGNED
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0), // Fine-tuned alignment
                            child: Icon(
                              Icons.location_on, 
                              color: AppStyles.primaryGreen, 
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.mosque.address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // City and Area
                    Text(
                      "${widget.mosque.city}, ${widget.mosque.area}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider with decorative elements
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Amenities",
                              style: TextStyle(
                                color: AppStyles.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Amenities
                    if (widget.mosque.amenities.isNotEmpty)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: widget.mosque.amenities.entries
                            .where((a) => a.value == true)
                            .map(
                              (a) => Chip(
                                backgroundColor: AppStyles.primaryGreen.withOpacity(0.1),
                                label: Text(
                                  a.key,
                                  style: TextStyle(
                                    color: AppStyles.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                avatar: Icon(
                                  Icons.check_circle,
                                  color: AppStyles.primaryGreen,
                                  size: 16,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Back button and centered prayer info
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 22, color: Colors.white),
                    ),
                  ),
                  
                  // Centered Prayer Info
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          currentPrayer.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          getRemainingTime(currentPrayer.value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Invisible spacer to balance the layout
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Show Route Button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          backgroundColor: AppStyles.primaryGreen,
          icon: const Icon(Icons.directions, color: Colors.white, size: 20),
          label: const Text(
            "Show Route",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: () {
            Navigator.pop(context, widget.mosque);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}