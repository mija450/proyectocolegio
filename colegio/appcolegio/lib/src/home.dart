import 'package:flutter/material.dart';
import 'login.dart';
import 'aprendizaje.dart';
import 'tareas.dart';
import 'eventos.dart';
import 'recursos.dart';
import 'comunicacion.dart';
import 'perfil.dart';
import 'cof.dart'; 
import 'encuestas.dart';
import 'biblioteca.dart';
import 'soporte.dart';
import 'reportes.dart';
import 'registro.dart';

class HomeScreen extends StatefulWidget {
  final String role; // "Estudiante", "Docente" o "Dirección"
  final String name; // Nombre del usuario

  const HomeScreen({
    super.key,
    required this.role,
    required this.name,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo blanco del diálogo
          title: const Text(
            'Confirmar Salida',
            style: TextStyle(color: Colors.black), // Color del texto
          ),
          content: const Text(
            '¿Estás seguro de que quieres salir?',
            style: TextStyle(color: Colors.black), // Color del texto
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón Cancelar
              ),
              child: const Text(
                "❌ Cancelar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Color del botón Salir
              ),
              child: const Text(
                "✅ Salir",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String sessionText = "Sesión activa: ${widget.name} - Rol: ${widget.role}";

    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Comprobar el modo oscuro

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, size: 28), // Icono de la escuela
            SizedBox(width: 10),
            Text('Menu Principal'),
          ],
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // Icono de campana para notificaciones
            onPressed: () {
              // Acción para ver notificaciones
              // Aquí puedes navegar a otra pantalla o mostrar un diálogo
            },
          ),
         IconButton(
  icon: const Icon(Icons.person_add), // Icono para registrarse
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroScreen()), // Cambia a RegistroScreen()
    );
  },
),
          IconButton(
            icon: const Icon(Icons.groups),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CofScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // Banner
            Container(
              height: 120,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner4.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              sessionText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Funciones:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildFeatureCard(
                    context,
                    'Comunicación',
                    'assets/images/comunicacion.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComunicacionScreen(
                            role: widget.role,
                            name: widget.name,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Aprendizaje',
                    'assets/images/aprendizaje.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AprendizajeScreen(
                            role: widget.role,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Tareas',
                    'assets/images/tarea.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TareasScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Eventos',
                    'assets/images/evento.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventosScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Recursos',
                    'assets/images/recursos.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecursosScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Biblioteca Digital',
                    'assets/images/biblioteca.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BibliotecaScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Encuestas',
                    'assets/images/encuesta.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EncuestasScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Soporte Técnico',
                    'assets/images/soporte.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SoporteScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Reportes',
                    'assets/images/reporte.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportesScreen(
                            role: widget.role,
                            name: widget.name,
                            isDarkMode: false,
                            onThemeChanged: (bool value) {},
                          ),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    'Perfil',
                    'assets/images/perfil.png',
                    Colors.blue[600]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilScreen(
                            name: widget.name,
                            role: widget.role,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: const Text(
          "© 2025 EducaPeru. Todos los derechos reservados.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
  BuildContext context,
  String title,
  String assetPath,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.black26, width: 1), // Borde sutil
      ),
      elevation: 5,
      color: color,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white), // Texto blanco
            ),
          ),
        ],
      ),
    ),
  );
}
}