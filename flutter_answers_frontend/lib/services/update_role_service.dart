import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> updateUserRole(int userId, String newRole) async {
  final serverUrl = dotenv.env['SERVER_URL'];
  final roleupdtendpoint = dotenv.env['UPDATE_ROLE_ENDPOINT'];
  final response = await http.put(
    Uri.parse('$serverUrl$roleupdtendpoint'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId, "role": newRole}),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to update role");
  }
}