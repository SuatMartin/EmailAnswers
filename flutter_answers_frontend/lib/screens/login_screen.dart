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

    // Store user_id
    if (responseData.containsKey('user_id')) {
      await prefs.setInt('user_id', responseData['user_id']);
      print("✅ User ID stored: ${responseData['user_id']}");
    }

    // Store username
    if (responseData.containsKey('username')) {
      await prefs.setString('username', responseData['username']);
      print("✅ Username stored: ${responseData['username']}");
    }

    // Store role
    if (responseData.containsKey('role')) {
      await prefs.setString('role', responseData['role']);
      print("✅ Role stored: ${responseData['role']}");
    }

    // Redirect user based on role
    if (responseData['redirect'] == '/admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/user');
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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              child: Text('Login'),
            ),
            TextButton(
              onPressed: _goToCreateAccount,
              child: Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}