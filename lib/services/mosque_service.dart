import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/utils/constant.dart';

class MosqueService {
 final String _baseUrl = AppConstants.MosqueUrl;

  Future<List<MosqueModel>> getNearbyMosques(
      double lat, double lng, {int radius = 500}) async {
    final uri = Uri.parse('http://192.168.0.117:5000/api/mosques/nearby?lat=$lat&lng=$lng&radius=$radius');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => MosqueModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load nearby mosques');
  }
}
