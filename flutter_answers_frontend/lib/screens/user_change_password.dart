import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Make sure you import the login screen

class UserChangePasswordScreen extends StatefulWidget {
  @override
  _UserChangePasswordScreenState createState() =>
      _UserChangePasswordScreenState();
}

class _UserChangePasswordScreenState extends State<UserChangePasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load the username from SharedPreferences when screen loads
  }

  // Load username from SharedPreferences
  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? ''; // Fetch username from SharedPreferences
    });
  }

  Future<void> changePassword() async {
    final String email = emailController.text.trim();
    final String newPassword = newPasswordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
      return;
    }

    final serverUrl = dotenv.env['SERVER_URL'];
    final passupdt = dotenv.env['PASS_UPDATE_ENDPOINT'];
    final removeFromTableEndpoint = dotenv.env['REMOVE_FROM_TABLE_ENDPOINT']; // New endpoint to remove user from the table
    // First, update the password
    final response = await http.put(
      Uri.parse('$serverUrl$passupdt'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'newPassword': newPassword}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );

      // Call the new endpoint to remove the user from the table
      final removeResponse = await http.delete(
        Uri.parse('$serverUrl$removeFromTableEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email}),
      );

      final removeResponseBody = jsonDecode(removeResponse.body);

      if (removeResponse.statusCode == 200) {
        // Successfully removed from the table
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(removeResponseBody['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(removeResponseBody['error'])),
        );
      }

      // Clear SharedPreferences to log the user out
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login'); // Replace with your login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['error'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
        centerTitle: true,
        backgroundColor: Colors.green, // Dark green top bar
      ),
      body: Container(
        color: Colors.green[50], // Light green background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Nombre de usuario: $username', // Display username fetched from SharedPreferences
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: changePassword,
              child: Text('Actualizar contraseña'),
            ),
            SizedBox(height: 30),
            // Add the logo at the bottom
            Image.asset('assets/IEPR.png', height: 100), // Update the path to your PNG logo
          ],
        ),
      ),
    );
  }
}