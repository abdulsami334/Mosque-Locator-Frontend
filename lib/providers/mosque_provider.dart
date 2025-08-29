import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/services/mosque_service.dart';

class MosqueProvider extends ChangeNotifier {
  final MosqueService _service = MosqueService();
  final String _baseUrl = 'http://192.168.18.20:5000/api/mosques/';

  // ✅ Nearby mosques list
  List<MosqueModel> _mosques = [];
  List<MosqueModel> get mosques => _mosques;

  // ✅ User's own mosques list
  List<MosqueModel> _myMosques = [];
  List<MosqueModel> get myMosques => _myMosques;

  // ✅ Counts
  int get nearbyMosqueCount => _mosques.length;
  int get myMosqueCount => _myMosques.length;

  // Auth + error
  String? _token;
  String? errorMessage;

  void setToken(String token) {
    _token = token;
  }

  /// ✅ Load nearby mosques
  Future<void> loadNearbyMosques(double lat, double lng, {int radius = 5000}) async {
    try {
      _mosques = await _service.getNearbyMosques(lat, lng, radius: radius);
    } catch (e) {
      debugPrint('Error loading nearby mosques: $e');
      _mosques = [];
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Add a new mosque
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
    required Map<String, bool> amenities,
  }) async {
    try {
      final mosqueData = {
        "name": name,
        "address": address,
        "city": city,
        "area": area,
        "location": {
          "type": "Point",
          "coordinates": [lng, lat], // backend expects [lng, lat]
        },
        "prayerTimes": {
          "fajr": fajr ?? "",
          "dhuhr": dhuhr ?? "",
          "asr": asr ?? "",
          "maghrib": maghrib ?? "",
          "isha": isha ?? "",
        },
        "amenities": amenities,
      };

      final response = await http.post(
        Uri.parse("$_baseUrl"),
        headers: {
          "Content-Type": "application/json",
          if (_token != null) "Authorization": "Bearer $_token",
        },
        body: jsonEncode(mosqueData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          errorMessage = decoded['message'] ?? decoded['error'] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }
        return false;
      }
    } catch (e) {
      errorMessage = "Server error: $e";
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Load user’s own mosques
  Future<void> loadMyMosques() async {
    try {
      final response = await http.get(
        Uri.parse("${_baseUrl}my"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _myMosques = data.map((e) => MosqueModel.fromJson(e)).toList();
      } else {
        _myMosques = [];
        errorMessage = response.body;
      }
    } catch (e) {
      debugPrint("Error loading my mosques: $e");
      _myMosques = [];
    } finally {
      notifyListeners();
    }
  }

  /// ✅ Update mosque
  Future<bool> updateMosque(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = jsonDecode(response.body)['message'] ?? 'Update failed';
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }
}
