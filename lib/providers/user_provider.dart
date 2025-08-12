import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/utils/constant.dart';

class AuthProvider with ChangeNotifier{
final String baseUrl = AppConstants.ContributorUrl;
bool isLoading = false;
String? _token;
  UserModel? _user;
String? errorMessage;
  String? get token => _token;
  UserModel? get user => _user;

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
  Future<bool> loginContributor(String email, String password, )async{
try{
  isLoading=true;
  notifyListeners();
final response =await http.post(Uri.parse("$baseUrl/login"),
   headers: {"Content-Type": "application/json"},
      body: jsonEncode({
          "email": email,
          "password": password,
        }),
        
);
isLoading = false;
      notifyListeners();
      if(response.statusCode==200){
        final data =jsonDecode(response.body);
        _token = data["token"];
        _user = UserModel.fromJson(data["contributor"]);
        debugPrint("✅ Logged in successfully, Token: $_token");
        return true;
      }else {
       // debugPrint(" Login failed: ${response.body}");
            final data = jsonDecode(response.body);
        errorMessage = data["message"];
        return false;
      }

}catch (e) {
      isLoading = false;
      notifyListeners();
      //debugPrint("❌ Error: $e");
       errorMessage = "Something went wrong";
      return false;
    }
  }

}