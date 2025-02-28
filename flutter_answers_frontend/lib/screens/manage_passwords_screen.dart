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
        SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
      return;
    }

    final serverUrl = dotenv.env['SERVER_URL'];
    final passupdt = dotenv.env['PASS_UPDATE_ENDPOINT'];
    final adminChange = dotenv.env['ADMIN_CHANGE_ENDPOINT'];
    
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
      
      // Log the admin change into admin_changed table
      await http.post(
        Uri.parse('$serverUrl$adminChange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email}),
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
        title: Text('Gestionar Contraseñas'),
        centerTitle: true,
        backgroundColor: Colors.green, // Green top bar
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/IEPR.png', // Make sure to add the PNG image in your assets folder
              height: 40,
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.green[50], // Light green background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
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
              onPressed: updatePassword,
              child: Text('Actualizar contraseña'),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/IEPR.png', // Add another image below the button
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
