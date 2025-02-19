import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/email_service.dart';

class EmailForm extends StatefulWidget {
  const EmailForm({super.key});

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _questionController = TextEditingController();

  String? _selectedTopic;
  String? _storedUsername;
  final List<String> _topics = [
    'Demografía,Poblacion,Censo', 
    'Economía', 
    'Salud', 
    'Geografía', 
    'Telecomunicaciones,Transportación,Carreteras',
    'Ambiental', 
    'Educación', 
    'Ciencia y Tecnología', 
    'Familia,Servicios Sociales', 
    'Justicia,Seguridad', 
    'Otros', 
    'Turismo', 
    'Cultura', 
    'Academias y Talleres'
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedUsername = prefs.getString('username') ?? 'Usuario';
    });
  }

  void _sendEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await EmailService.sendEmail(
          topic: _selectedTopic ?? '', 
          toName: _recipientController.text,
          toEmail: _emailController.text,
          fromName: _storedUsername ?? 'Usuario',
          question: _questionController.text,
          message: _messageController.text,
          context: context, 
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedTopic,
            hint: Text('Escoja un Topico'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTopic = newValue;
              });
            },
            validator: (value) => value == null ? 'Por favor escoja un tópico' : null,
            items: _topics.map<DropdownMenuItem<String>>((String topic) {
              return DropdownMenuItem<String>(
                value: topic,
                child: Text(topic),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _recipientController,
            decoration: InputDecoration(labelText: 'Escriba el nombre del recipiente'),
            validator: (value) => value!.isEmpty ? 'Por favor escriba el nombre del recipiente' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email del recipiente'),
            validator: (value) => value!.isEmpty || !value.contains('@') ? 'Por favor escriba el email del recipiente' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(labelText: 'La pregunta'),
            validator: (value) => value!.isEmpty ? 'Por favor ingrese el título de la pregunta que está contestando' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(labelText: 'Respuesta'),
            maxLines: 4,
            validator: (value) => value!.isEmpty ? 'Escriba su respuesta' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendEmail,
            child: Text('Enviar Email'),
          ),
        ],
      ),
    );
  }
}
