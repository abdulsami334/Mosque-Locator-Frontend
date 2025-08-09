import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/services/mosque_service.dart';

class MosqueProvider extends ChangeNotifier {
  final MosqueService _service = MosqueService();

  List<MosqueModel> _mosques = [];
  List<MosqueModel> get mosques => _mosques;

  Future<void> loadNearbyMosques(double lat, double lng,
      {int radius = 5000}) async {
    try {
      _mosques = await _service.getNearbyMosques(lat, lng, radius: radius);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby mosques: $e');
    }
  }
}
