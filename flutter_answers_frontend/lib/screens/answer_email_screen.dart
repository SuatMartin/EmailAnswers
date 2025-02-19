import 'package:flutter/material.dart';
import '../widgets/email_form.dart';

class AnswerEmailScreen extends StatelessWidget {
  const AnswerEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Llene los campos abajo para enviar su respuesta'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[100],
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EmailForm(),
      ),
    );
  }
}