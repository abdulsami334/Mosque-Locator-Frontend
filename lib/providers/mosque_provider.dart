import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/services/mosque_service.dart';
import 'package:mosque_locator/utils/constant.dart';

class MosqueProvider extends ChangeNotifier {
  final MosqueService _service = MosqueService();
  final String _baseUrl = 'http://192.168.0.117:5000/api/mosques/';

  List<MosqueModel> _mosques = [];
  List<MosqueModel> get mosques => _mosques;

  String? _token;
  String? errorMessage;

  void setToken(String token) {
    _token = token;
   // notifyListeners();
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
  required Map<String, bool> amenities,
}) async {
  try {
    print("TOKEN USED: $_token");

    final mosqueData = {
      "name": name,
      "address": address,
      "city": city,
      "area": area,
        "location": {
    "type": "Point",
    "coordinates": [lng, lat], // double values
  },// 👈 Make sure backend expects [lng, lat]
      "prayerTimes": {
        "fajr": fajr ?? "",
        "dhuhr": dhuhr ?? "",
        "asr": asr ?? "",
        "maghrib": maghrib ?? "",
        "isha": isha ?? "",
      },
      "amenities": amenities,
    };

    print("Sending data: ${jsonEncode(mosqueData)}");

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      },
      body: jsonEncode(mosqueData),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

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
  } catch (e, s) {
    print("Exception: $e");
    print("Stack: $s");
    errorMessage = "Server error: $e";
    return false;
  } finally {
    notifyListeners();
  }
}


Future<List<MosqueModel>> getMyMosques() async {
  try {
    print("1) Inside getMyMosques");
    print("TOKEN USED: $_token");

    final response = await http.get(
      Uri.parse("http://192.168.0.117:5000/api/mosques/my"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );

    print("2) Status code: ${response.statusCode}");
    print("3) Raw body: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print("4) Backend list length: ${data.length}");
      return data.map((e) => MosqueModel.fromJson(e)).toList();
    } else {
      print("5) Error body: ${response.body}");
      return [];
    }
  } catch (e, s) {
    print("6) Exception: $e");
    print("7) Stack: $s");
    return [];
  }
}
Future<bool> updateMosque(String id, Map<String, dynamic> updates, )async{
try{
final response = await http.put(Uri.parse("$_baseUrl/$id"),
headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode(updates),
); 

if(response.statusCode==200){
  return true;
}else {
      errorMessage = jsonDecode(response.body)['message'];
      return false;
    }
}
 catch (e) {
    errorMessage = e.toString();
    return false;
  }
}}

