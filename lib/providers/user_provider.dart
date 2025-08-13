// auth_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/user_model.dart';
import 'package:mosque_locator/utils/constant.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = AppConstants.ContributorUrl;
  bool isLoading = false;
  String? _token;
  UserModel? _user;
  String? errorMessage;

  String? get token => _token;
  UserModel? get user => _user;

  // ✅ Register contributor
  Future<bool> registerContributor(UserModel user) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      isLoading = false;

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        _token = data['token'];
        _user = UserModel.fromJson(
          data['contributor'] != null
              ? (data['contributor']['contributor'] ?? data['contributor'])
              : data,
        );
        notifyListeners();
        return true;
      } else {
        errorMessage = data['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Server error';
      notifyListeners();
      return false;
    }
  }

  // ✅ Login contributor
  Future<bool> loginContributor(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      isLoading = false;

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _token = data['token'];
        _user = UserModel.fromJson(
          data['contributor'] != null
              ? (data['contributor']['contributor'] ?? data['contributor'])
              : data,
        );
        notifyListeners();
        return true;
      } else {
        errorMessage = data['message'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Server error';
      notifyListeners();
      return false;
    }
  }
Future<bool> updateProfilePicture(String filePath) async {
  try {
    isLoading = true;
    notifyListeners();

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/update-profile-picture'), // backend route
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      _user = UserModel.fromJson(data['contributor']);
      return true;
    } else {
      debugPrint("❌ Failed: ${responseData.body}");
      return false;
    }
  } catch (e) {
    isLoading = false;
    notifyListeners();
    debugPrint("❌ Error: $e");
    return false;
  }
}


}