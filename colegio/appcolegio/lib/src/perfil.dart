import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'solicitudes.dart';
import 'editar_perfil.dart';

class PerfilScreen extends StatefulWidget {
  final String name; // Nombre del usuario en sesión
  final String role; // Rol del usuario en sesión

  const PerfilScreen({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String nombre = "";
  String correo = "";
  String rol = "";

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/perfil.php");
    try {
      final response = await http.post(url, body: {
        'nombre': widget.name, // Enviar el nombre de sesión al servidor
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            nombre = data['data']['nombre'] ?? 'Desconocido';
            correo = data['data']['correo'] ?? 'No disponible';
            rol = data['data']['rol'] ?? 'No asignado';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al obtener perfil")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _irEditarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilScreen(
          nombreActual: nombre,
          correoActual: correo,
        ),
      ),
    ).then((resultado) {
      if (resultado == true) {
        _cargarPerfil(); // Recarga el perfil si se edita
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blue[800], // Color del AppBar
        actions: [
          if (widget.role.toLowerCase() == "direccion")
            IconButton(
              icon: const Icon(Icons.person, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SolicitudesScreen()),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/comunicados_portada.png'), // Imagen de portada
            const SizedBox(height: 16),
            const Text(
              '👤 Información del Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildProfileInfo('Nombre:', nombre),
            _buildProfileInfo('Correo Electrónico:', correo),
            _buildProfileInfo('Rol:', rol),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _irEditarPerfil,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Color del botón
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                ),
              ), // Navegar a editar_perfil.dart
              child: const Text('✏️ Editar Perfil'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        '$label $value',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}