import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'user'; // Default role is 'user'
  bool _isAdmin = false; // Admin check flag

  // Function to check if the logged-in user is an admin
  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role'); // Retrieve stored role

    setState(() {
      if (role == 'admin') {
        _isAdmin = true; // If role is admin, allow role selection
      } else {
        _role = 'user'; // If not admin, keep the role as 'user'
      }
    });
  }

  Future<void> _register() async {
    final serverUrl = dotenv.env['SERVER_URL'];
    final regendpoint = dotenv.env['REGISTER_ENDPOINT'];
    final response = await http.post(
      Uri.parse('$serverUrl$regendpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _usernameController.text,
        'password': _passwordController.text,
        'username': _nameController.text,
        'role': _role,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['error'])),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole(); // Check user role on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            if (_isAdmin) // Show role dropdown only if the user is an admin
              DropdownButton<String>(
                value: _role,
                onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                items: <String>['user', 'admin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}