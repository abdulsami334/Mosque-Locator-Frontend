import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/user_model.dart';

class AuthProvider with ChangeNotifier{
final String baseUrl = "http://192.168.18.20:5000/api/contributors";
bool isLoading = false;

  Future<bool>  registerContributor(UserModel user) async {

try{
isLoading = true;
      notifyListeners();

      final response=await http.post(
          Uri.parse("$baseUrl/register"), // backend route ke hisaab se
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );  isLoading = false;
      notifyListeners();
 if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Register failed: ${response.body}");
        return false;
      }
}catch(e){
   isLoading = false;
      notifyListeners();
      debugPrint("Error: $e");
      return false;
}




  }

}