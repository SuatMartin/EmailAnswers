import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminCheckService {
  static Future<void> checkAdmin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (role != 'admin') {
      // Redirect to login if user is not an admin
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}