import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/admin_check_service.dart';

class ManagePasswordsScreen extends StatefulWidget {
  @override
  _ManagePasswordsScreenState createState() => _ManagePasswordsScreenState();
}

class _ManagePasswordsScreenState extends State<ManagePasswordsScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AdminCheckService.checkAdmin(context); // ✅ Check admin access when screen loads
  }

  Future<void> updatePassword() async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String newPassword = newPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    final serverUrl = dotenv.env['SERVER_URL'];
    final passupdt = dotenv.env['PASS_UPDATE_ENDPOINT'];
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
        title: Text('Manage Passwords'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updatePassword,
              child: Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}