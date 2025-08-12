import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/utils/constant.dart';

class MosqueService {
 String _baseUrl = AppConstants.MosqueUrl;

  Future<List<MosqueModel>> getNearbyMosques(
      double lat, double lng, {int radius = 500}) async {
    final uri = Uri.parse('$_baseUrl/nearby?lat=$lat&lng=$lng&radius=$radius');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => MosqueModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load nearby mosques');
  }
}
