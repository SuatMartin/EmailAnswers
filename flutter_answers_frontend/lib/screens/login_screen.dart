import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final serverUrl = dotenv.env['SERVER_URL'];
    final logendpoint = dotenv.env['LOGIN_ENDPOINT'];
    final adminChangeCheck = dotenv.env['ADMIN_CHANGE_CHECK_ENDPOINT'];

    final response = await http.post(
      Uri.parse('$serverUrl$logendpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      if (responseData.containsKey('user_id')) {
        await prefs.setInt('user_id', responseData['user_id']);
      }
      if (responseData.containsKey('username')) {
        await prefs.setString('username', responseData['username']);
      }
      if (responseData.containsKey('role')) {
        await prefs.setString('role', responseData['role']);
      }

      // Check if user is in admin_changed table
      final adminCheckResponse = await http.post(
        Uri.parse('$serverUrl$adminChangeCheck'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _usernameController.text,
        }),
      );

      final adminCheckData = json.decode(adminCheckResponse.body);
    

      if (adminCheckResponse.statusCode == 200 && adminCheckData['requiresPasswordChange']) {
        Navigator.pushReplacementNamed(context, '/user_change_password');
      } else {
        if (responseData['redirect'] == '/admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/user');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['error'])),
      );
    }
  }

  void _goToCreateAccount() {
    Navigator.pushNamed(context, '/create-account');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _goToCreateAccount,
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text('Crear una Cuenta'),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/IEPR.png',
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
