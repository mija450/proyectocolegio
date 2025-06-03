import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SoporteScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario

  const SoporteScreen({
    super.key,
    required this.role,
    required this.name,
    required bool isDarkMode,
    required Null Function(bool value) onThemeChanged,
  });

  @override
  _SoporteScreenState createState() => _SoporteScreenState();
}

class _SoporteScreenState extends State<SoporteScreen> {
  List<dynamic> preguntasFrecuentes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPreguntasFrecuentes();
  }

  Future<void> _fetchPreguntasFrecuentes() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/soporte.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            preguntasFrecuentes = data['data'];
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _showConsultaDialog() {
    String pregunta = '';
    String respuesta = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enviar Consulta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Ingrese su pregunta'),
                onChanged: (value) {
                  pregunta = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Respuesta (opcional)'),
                onChanged: (value) {
                  respuesta = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () {
                _enviarConsulta(pregunta, respuesta);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWarningMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Advertencia de Soporte Técnico'),
          content: const Text('Por favor, asegúrese de proporcionar toda la información necesaria al enviar su consulta para que podamos ayudarle mejor.'),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarConsulta(String pregunta, String respuesta) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_soporte.php");
    
    try {
      final response = await http.post(url, body: {
        'titulo': pregunta,
        'descripcion': respuesta,
        'fecha': DateTime.now().toIso8601String(),
      });

      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consulta enviada con éxito")),
        );
        _fetchPreguntasFrecuentes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message'] ?? 'Desconocido'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildPreguntaItem(String pregunta, String respuesta) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(pregunta, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(respuesta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Mostrar Advertencia",
            onPressed: _showWarningMessage,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Enviar Consulta",
            onPressed: _showConsultaDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar preguntas frecuentes"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
                      const SizedBox(height: 16),
                      const Text(
                        'Preguntas Frecuentes',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: preguntasFrecuentes.length,
                          itemBuilder: (context, index) {
                            final pregunta = preguntasFrecuentes[index];
                            return _buildPreguntaItem(
                              pregunta['pregunta'] ?? 'Pregunta no disponible',
                              pregunta['respuesta'] ?? 'Respuesta no disponible',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}