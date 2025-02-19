import 'package:flutter/material.dart';
import 'answer_email_screen.dart'; // Import the AnswerEmailScreen file
import 'users_page.dart'; // Import the UsersPage file
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
    AdminCheckService.checkAdmin(context); // ✅ Only runs once on load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersPage()),
                );
              },
              child: Text('View Users'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagePasswordsScreen()),
                );
              },
              child: Text('Manage Passwords'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAccountScreen()),
                );
              },
              child: Text('Create New User'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnswerEmailScreen()),
                );
              },
              child: Text('Answer Email'),
            ),
          ],
        ),
      ),
    );
  }
}