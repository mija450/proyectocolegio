import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  String _rol = ""; // "docente" o "alumno"
  String _nombre = "";
  String _correo = "";
  String _codigo = "";

  int _currentStep = 0;
  final _stepperKey = GlobalKey<FormState>();

  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController codigoController = TextEditingController();

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  Future<void> _registrar() async {
    // Mostrar un diálogo de confirmación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo azul
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          title: const Text("Confirmación", style: TextStyle(color: Colors.black)),
          content: const Text(
            "¿Estás seguro de que deseas guardar este anuncio?",
            style: TextStyle(color: Colors.black), // Mensaje negro
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false), // Cierra el diálogo y retorna false
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón Cancelar
              ),
              child: const Text(
                "❌ Cancelar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Cierra el diálogo y retorna true
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Color del botón Aceptar
              ),
              child: const Text(
                "✅ Aceptar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ],
        );
      },
    );

    // Si el usuario cancela, salir del método
    if (confirm != true) return;

    final url = Uri.parse("http://127.0.0.1/ProyectoColegio/Colegio/registro.php");

    try {
      final response = await http.post(url, body: {
        'rol': _rol,
        'nombre': _nombre,
        'correo': _correo,
        'codigo': _codigo,
      });

      final data = json.decode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error al registrar")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.blue[800], // Color del AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Registro de Usuarios",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _stepperKey,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 3) {
                      if (_validateStep(_currentStep)) {
                        _registrar();
                      }
                    } else {
                      if (_validateStep(_currentStep)) {
                        _nextStep();
                      }
                    }
                  },
                  onStepCancel: _previousStep,
                  steps: _buildSteps(),
                  controlsBuilder: (context, details) {
                    final isLastStep = (_currentStep == 3);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text("Atrás"),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            backgroundColor: Colors.white, // Fondo blanco
                            side: const BorderSide(color: Colors.blue), // Borde azul
                          ),
                          child: Text(
                            isLastStep ? "Finalizar" : "Continuar",
                            style: const TextStyle(color: Colors.blue), // Texto azul
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_rol.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Seleccione Docente o Alumno")),
          );
          return false;
        }
        return true;
      case 1:
        if (nombreController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingrese su nombre")),
          );
          return false;
        }
        _nombre = nombreController.text.trim();
        return true;
      case 2:
        if (correoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingrese su correo")),
          );
          return false;
        }
        // Validación del correo
        if (!RegExp(r'^[\w-\.]+@(gmail\.com|hotmail\.com)$').hasMatch(correoController.text.trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Por favor, ingrese un correo válido de Gmail o Hotmail")),
          );
          return false;
        }
        _correo = correoController.text.trim();
        return true;
      case 3:
        if (codigoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ingrese su código")),
          );
          return false;
        }
        _codigo = codigoController.text.trim();
        return true;
      default:
        return true;
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("1. Rol"),
        content: _stepRol(),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text("2. Nombre"),
        content: _stepNombre(),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text("3. Correo"),
        content: _stepCorreo(),
        isActive: _currentStep == 2,
      ),
      Step(
        title: const Text("4. Código"),
        content: _stepCodigo(),
        isActive: _currentStep == 3,
      ),
    ];
  }

  Widget _stepRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selecciona tu Rol",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        RadioListTile<String>(
          title: const Text("Docente"),
          value: "docente",
          groupValue: _rol,
          onChanged: (value) {
            setState(() {
              _rol = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text("Alumno"),
          value: "alumno",
          groupValue: _rol,
          onChanged: (value) {
            setState(() {
              _rol = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _stepNombre() {
    return _buildInputField(
      controller: nombreController,
      label: "Nombre completo",
      hint: "Ingresa tu Nombre",
    );
  }

  Widget _stepCorreo() {
    return _buildInputField(
      controller: correoController,
      label: "Correo Electrónico",
      hint: "Ingresa tu Correo",
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _stepCodigo() {
    return _buildInputField(
      controller: codigoController,
      label: "Código (contraseña)",
      hint: "Crea tu Código",
      obscureText: true,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}