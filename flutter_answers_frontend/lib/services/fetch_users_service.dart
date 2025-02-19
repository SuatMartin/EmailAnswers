import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<User>> fetchUsers() async {
  final serverUrl = dotenv.env['SERVER_URL'];
  final getuserendpoint = dotenv.env['GET_USER_ENDPOINT'];
  final response = await http.get(Uri.parse('$serverUrl$getuserendpoint'));

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');  // Debugging line to print the response
    try {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Extract the list of users from the 'users' key
      List<dynamic> usersList = jsonResponse['users'];
      return usersList.map((user) => User.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  } else {
    throw Exception('Failed to load users');
  }
}

Future<void> deleteUser(int userId) async {
  final serverUrl = dotenv.env['SERVER_URL'];
  final deletendpoint = dotenv.env['DELETE_ENDPOINT'];
  final response = await http.delete(
    Uri.parse('$serverUrl$deletendpoint$userId'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete user');
  }
}

class User {
  final int userId;
  final String username;
  final String email;
  final String password;
  final String role; // Add role field

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.password,
    required this.role, // Include role in constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      role: json['role'], // Parse role from JSON
    );
  }
}