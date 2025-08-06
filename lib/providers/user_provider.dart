import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void login(String email, String password) {
    // Static login logic
    _user = UserModel(name: "Abdul Sami", email: email);
    notifyListeners();
  }

  void signup(String name, String email, String password) {
    _user = UserModel(name: name, email: email);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
