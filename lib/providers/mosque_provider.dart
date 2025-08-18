import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/services/mosque_service.dart';
import 'package:mosque_locator/utils/constant.dart';

class MosqueProvider extends ChangeNotifier {
  final MosqueService _service = MosqueService();
  final String _baseUrl = AppConstants.MosqueUrl;

  List<MosqueModel> _mosques = [];
  List<MosqueModel> get mosques => _mosques;

  String? _token;
  String? errorMessage;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  Future<void> loadNearbyMosques(double lat, double lng, {int radius = 5000}) async {
    try {
      _mosques = await _service.getNearbyMosques(lat, lng, radius: radius);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby mosques: $e');
    }
  }

  Future<bool> addMosque({
    required String name,
    required String address,
    required String city,
    required String area,
    required double lat,
    required double lng,
      String? fajr,
  String? dhuhr,
  String? asr,
  String? maghrib,
  String? isha,
  }) async {
    try {
      print("TOKEN USED: $_token");
      final response = await http.post(
        Uri.parse("$_baseUrl"),
        headers: {
          "Content-Type": "application/json",
          if (_token != null) "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "name": name,
          "address": address,
          "city": city,
          "area": area,
          "location": {
            "type": "Point",
            "coordinates": [lng, lat]
          },"namazTimings": {
          "fajr": fajr,
          "dhuhr": dhuhr,
          "asr": asr,
          "maghrib": maghrib,
          "isha": isha,
        }

          
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error';
        return false;
      }
    } catch (e) {
      errorMessage = "Server error";
      return false;
    } finally {
      notifyListeners(); // spinner off
    }
  }
}