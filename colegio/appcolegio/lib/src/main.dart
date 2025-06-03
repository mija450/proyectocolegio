import 'package:flutter/material.dart';
import 'home.dart';
import 'comunicacion.dart';
import 'aprendizaje.dart';
import 'tareas.dart';
import 'eventos.dart';
import 'recursos.dart';
import 'perfil.dart';
import 'cof.dart'; 
import 'login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(ColegioApp());
}

class ColegioApp extends StatefulWidget {
  const ColegioApp({super.key});

  @override
  _ColegioAppState createState() => _ColegioAppState();
}

class _ColegioAppState extends State<ColegioApp> with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;

  String userRole = "docente";
  String userName = "Juan Pérez";

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Comunicación y Aprendizaje',
      theme: ThemeData(
        primarySwatch: Colors.grey, // Puedes usar un color neutro como gris
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Fondo blanco
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          bodyMedium: TextStyle(
            color: _isDarkMode ? Colors.white70 : Colors.black54,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(
              role: userRole,
              name: userName,
            ),
        '/comunicacion': (context) => ComunicacionScreen(
              role: userRole,
              name: userName,
            ),
        '/aprendizaje': (context) => AprendizajeScreen(
              role: userRole,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/tareas': (context) => TareasScreen(
              role: userRole,
              name: userName,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/eventos': (context) => EventosScreen(
              role: userRole,
              name: userName,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/recursos': (context) => RecursosScreen(
              role: userRole,
              name: userName,
              isDarkMode: _isDarkMode,
              onThemeChanged: (value) {
                _toggleDarkMode();
              },
            ),
        '/configuracion': (context) => const CofScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Eliminar el Positioned que contiene el icono de ojo
          ],
        );
      },
    );
  }
}