import 'package:flutter/material.dart';
import 'answer_email_screen.dart';
import 'users_page.dart';
import '../services/admin_check_service.dart';
import 'create_account_screen.dart';
import 'manage_passwords_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    AdminCheckService.checkAdmin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // ✅ Light green background
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/IEPR.png', // ✅ Replace with your top image
              height: 40, // Adjust height as needed
            ),
            SizedBox(width: 10),
            Text('Admin Page'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green, // ✅ Green top bar
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300, // ✅ Narrower width for vertical layout
                height: 500, // ✅ Increased height for better spacing
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green, // ✅ Green container
                  borderRadius: BorderRadius.circular(15), // ✅ Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton('Ver Usuarios', UsersPage(), Colors.yellow),
                    SizedBox(height: 60), // ✅ More space between buttons
                    _buildButton('Manejar Passwords', ManagePasswordsScreen(), Colors.red),
                    SizedBox(height: 60),
                    _buildButton('Crear Nuevo Usuario', CreateAccountScreen(), Colors.blue),
                    SizedBox(height: 60),
                    _buildButton('Contestar Email', AnswerEmailScreen(), Colors.green[800]!),
                  ],
                ),
              ),
            ),
          ),
          Image.asset(
            'assets/IEPR.png', // ✅ Replace with your bottom image
            height: 100, // Adjust height as needed
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Widget page, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(250, 50), // ✅ Set a fixed width for buttons
        backgroundColor: color, // ✅ Custom button color
      ),
      child: Text(text, style: TextStyle(color: Colors.black)), // ✅ Black text for contrast
    );
  }
}