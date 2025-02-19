import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmationScreen extends StatelessWidget {
  // URL to navigate
  final String _linkedinUrl = 'https://estadisticas.pr/';

  const ConfirmationScreen({super.key});

  // Function to open the URL
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(_linkedinUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_linkedinUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmación'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[100],
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Su pregunta ha sido enviada, y recibirá una respuesta lo más pronto posible.',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _launchUrl,
                child: Text(
                  'Presione aquí para volver a la página principal',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}