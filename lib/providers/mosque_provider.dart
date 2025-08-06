import 'package:flutter/material.dart';
import 'package:mosque_locator/models/mosque_model.dart';
import 'package:mosque_locator/services/mosque_service.dart';

class MosqueProvider  with ChangeNotifier{
  final MosqueService _mosqueService=MosqueService();
  List<MosqueModel> _mosques = [];
  List<MosqueModel> get mosques=>_mosques;
    Future<void> loadMosques() async {
    _mosques = await _mosqueService.fetchMosque();
    notifyListeners();
  }

}