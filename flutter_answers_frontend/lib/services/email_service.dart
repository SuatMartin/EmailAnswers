import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../screens/confirmation_screen.dart';

class EmailService {
  static String sanitizeInput(String input) {
    return parse(input).documentElement?.text ?? '';
  }

  static Future<void> sendEmail({
    required String topic,
    required String toName,
    required String toEmail,
    required String fromName,
    required String question,
    required String message,
    required BuildContext context,
  }) async {
    // Sanitize inputs
    String sanitizedTopic = sanitizeInput(topic);
    String sanitizedToName = sanitizeInput(toName);
    String sanitizedToEmail = sanitizeInput(toEmail);
    String sanitizedFromName = sanitizeInput(fromName);
    String sanitizedQuestion = sanitizeInput(question);
    String sanitizedMessage = sanitizeInput(message);

    final emailJsUrl = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final serviceId = dotenv.env['SERVICE_ID'];
    final templateId = dotenv.env['TEMPLATE_ID'];
    final userId = dotenv.env['USER_ID'];

    try {
      // Send email
      final emailResponse = await http.post(
        emailJsUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "topic": sanitizedTopic,
            "to_name": sanitizedToName,
            "to_email": sanitizedToEmail,
            "from_name": sanitizedFromName,
            "question": sanitizedQuestion,
            "message": sanitizedMessage,
          }
        }),
      );

      if (emailResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sent successfully!')),
        );

        // Send data to Node.js backend to update database
        await _updateDatabase(fromName: sanitizedFromName, question: sanitizedQuestion);

        // Navigate to Confirmation Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
        );
      } else {
        throw Exception('Failed to send email: ${emailResponse.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  static Future<void> _updateDatabase({
    required String fromName,
    required String question,
  }) async {
    final serverUrl = dotenv.env['SERVER_URL'];
    final dataupdtendpoint = dotenv.env['DATA_UPDATE_ENDPOINT'];
    final Uri nodeJsUrl = Uri.parse('$serverUrl$dataupdtendpoint');

    try {
      final response = await http.post(
        nodeJsUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "from_name": fromName,
          "question": question,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Database updated successfully!");
      } else {
        print("❌ Failed to update database: ${response.body}");
      }
    } catch (error) {
      print("❌ Error updating database: $error");
    }
  }
}