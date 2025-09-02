import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_locator/models/notification_model.dart';
import 'package:mosque_locator/utils/constant.dart';

class NotificationProvider with ChangeNotifier
{
//  final String _baseUrl = "${AppConstants.notificationUrl}/notifications";
    String? _token;
  List<NotificationModel> _notifications = [];
  String? errorMessage;
    List<NotificationModel> get notifications => _notifications;
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
Future<void> fetchNotifications() async {
  try {
    final response = await http.get(
      Uri.parse("http://192.168.18.20:5000/api/notifications"),
      headers: {
        "Authorization": "Bearer $_token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      _notifications = data
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      errorMessage = null; // agar pehle error set hua tha to clear kar do
      notifyListeners();
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      errorMessage = body['message'] ?? "Failed to load notifications";
      notifyListeners();
    }
  } catch (e) {
    errorMessage = e.toString();
    notifyListeners();
  }
}
}