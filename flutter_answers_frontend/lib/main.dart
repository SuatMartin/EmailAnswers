import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/answer_email_screen.dart';  // Import the AnswerEmailScreen
import 'screens/admin_page.dart';  // Import the AdminPage
import 'screens/user_change_password.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/create-account': (context) => CreateAccountScreen(),
        '/user': (context) => AnswerEmailScreen(),  // Updated route
        '/admin': (context) => AdminPage(),  // New route for AdminPage
        '/user_change_password': (context) => UserChangePasswordScreen(),
      },
    );
  }
}