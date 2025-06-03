import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'agregar_biblioteca.dart'; // Importa el archivo para agregar bibliotecas
import 'configuraciones_biblioteca.dart'; // Importa el archivo de configuraciones de biblioteca
import 'buscar_biblioteca.dart'; // Importa el archivo de búsqueda de biblioteca
import 'package:url_launcher/url_launcher.dart'; // Importa el paquete para lanzar URLs

class BibliotecaScreen extends StatefulWidget {
  final String role; // "Estudiante" o "Docente"
  final String name; // Nombre del usuario
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const BibliotecaScreen({
    super.key,
    required this.role,
    required this.name,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _BibliotecaScreenState createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  List<dynamic> recursos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  Future<void> _fetchRecursos() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/biblioteca.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            recursos = data['data'];
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

  Widget _buildRecursoItem(String code, String title, String description, String author, String type, String? enlace, String? fechaPublicacion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Text("Autor: $author", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text("Código: $code", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text("Fecha de Publicación: ${fechaPublicacion ?? 'No disponible'}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        trailing: const Icon(Icons.book, color: Colors.green),
        onTap: enlace != null && enlace.isNotEmpty ? () async {
          final Uri url = Uri.parse(enlace);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            throw 'No se puede abrir el enlace: $enlace';
          }
        } : null,
      ),
    );
  }

  void _navigateToAgregarBiblioteca() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarBibliotecaScreen()),
    ).then((_) {
      // Refresca la lista de recursos cuando regresa
      _fetchRecursos();
    });
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = widget.role.toLowerCase() == "estudiante"
        ? "Sesión activa del alumno: ${widget.name}"
        : "Sesión activa del docente: ${widget.name}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Buscar Recursos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuscarBibliotecaScreen()),
              ).then((_) {
                _fetchRecursos(); // Recargar recursos después de volver de la búsqueda
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Configuraciones de Biblioteca",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfiguracionesBibliotecaScreen(
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              ).then((_) {
                _fetchRecursos(); // Recargar recursos después de volver de configuraciones
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Error al cargar recursos"))
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
                        'Recursos Disponibles',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: recursos.length,
                          itemBuilder: (context, index) {
                            final recurso = recursos[index];
                            return _buildRecursoItem(
                              recurso['codigo'] ?? 'Código no disponible',
                              recurso['titulo'] ?? 'Título no disponible',
                              recurso['descripcion'] ?? 'Descripción no disponible',
                              recurso['autor'] ?? 'Autor no disponible',
                              recurso['tipo'] ?? 'Tipo no disponible',
                              recurso['enlace'], // Pasar enlace para abrir en navegador
                              recurso['fecha_publicacion'], // Pasar fecha de publicación
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