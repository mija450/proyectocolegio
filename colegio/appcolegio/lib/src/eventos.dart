import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Para dar formato a las fechas
import 'configuraciones_eventos.dart';

class EventosScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const EventosScreen({
    super.key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _EventosScreenState createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  List<dynamic> eventos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/eventos.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            eventos = data['data'];
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

  Future<void> _addEvento(String titulo, String descripcion, DateTime fecha, String hora, String lugar) async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/agregar_evento.php");

    try {
      final response = await http.post(url, body: {
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'lugar': lugar,
      });

      if (response.statusCode == 200) {
        _fetchEventos(); // Actualiza la lista de eventos
      } else {
        print("Error al agregar evento: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = "";
    if (widget.role.toLowerCase() == "estudiante") {
      sessionText = "Sesión activa del alumno: ${widget.name}";
    } else if (widget.role.toLowerCase() == "docente") {
      sessionText = "Sesión activa del docente: ${widget.name}";
    } else {
      sessionText = "Sesión activa de: ${widget.name}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.role.toLowerCase() == "docente")
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Configuraciones de Eventos",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionesEventosScreen(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar eventos"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
                      const SizedBox(height: 16),
                      Text(
                        sessionText,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Eventos Programados',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: eventos.length,
                          itemBuilder: (context, index) {
                            final evento = eventos[index];
                            return _buildEventItem(
                              evento['titulo'] ?? 'Título no disponible',
                              "${evento['descripcion'] ?? 'Descripción no disponible'}\nFecha: ${evento['fecha'] ?? 'Fecha no disponible'}\nHora: ${evento['hora'] ?? 'Hora no disponible'}\nLugar: ${evento['lugar'] ?? 'Lugar no disponible'}",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEventItem(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(description),
        trailing: const Icon(Icons.calendar_today, color: Colors.green),
      ),
    );
  }

  void _showAddEventoDialog() {
    String titulo = '';
    String descripcion = '';
    DateTime? fecha;
    String hora = '';
    String lugar = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) {
                  titulo = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (value) {
                  descripcion = value;
                },
              ),
              GestureDetector(
                onTap: () async {
                  fecha = await _selectDate(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      hintText: fecha != null ? DateFormat.yMd().format(fecha!) : 'Seleccionar fecha',
                    ),
                  ),
                ),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
                onChanged: (value) {
                  hora = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Lugar'),
                onChanged: (value) {
                  lugar = value;
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
              child: const Text('Agregar'),
              onPressed: () {
                if (titulo.isNotEmpty && descripcion.isNotEmpty && fecha != null && hora.isNotEmpty && lugar.isNotEmpty) {
                  _addEvento(titulo, descripcion, fecha!, hora, lugar);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, completa todos los campos.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime? selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}