import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Controladores para los 4 campos necesarios
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // NUEVO
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registrarUsuario() async {
    // 1. Validar que nada esté vacío
    if (_nombreController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _matriculaController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _mostrarMensaje("Por favor, llena todos los campos", Colors.red);
      return;
    }

    _mostrarCarga();

    try {
      // 2. CREAR USUARIO EN FIREBASE AUTH (El sistema de correos)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. GUARDAR DATOS EXTRAS EN FIRESTORE (Nombre, matrícula, rol)
      // Usamos el UID que nos dio Firebase Auth para que estén vinculados
      await FirebaseFirestore.instance.collection('Usuarios').doc(userCredential.user!.uid).set({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'matricula': _matriculaController.text.trim(),
        'rol': 'estudiante', // Por defecto
        'fecha_registro': DateTime.now(),
      });

      if (!mounted) return;
      Navigator.pop(context); // Quitar carga

      _mostrarMensaje("¡Bienvenido al TigreBus, Tigre!", Colors.green);
      Navigator.pop(context); // Regresar al Login

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      String errorMsg = "Error al registrar";
      if (e.code == 'email-already-in-use') errorMsg = "Este correo ya está registrado";
      if (e.code == 'weak-password') errorMsg = "La contraseña es muy débil";
      _mostrarMensaje(errorMsg, Colors.red);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _mostrarMensaje("Error inesperado: $e", Colors.red);
    }
  }

  void _mostrarCarga() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF3B009))),
    );
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF60A5FA)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.person_add_alt_1_rounded, size: 70, color: Colors.white),
              const Text("Nuevo Tigre", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                ),
                child: Column(
                  children: [
                    _campoTexto(_nombreController, "Nombre Completo", Icons.person_outline),
                    const SizedBox(height: 15),
                    _campoTexto(_emailController, "Correo Universitario", Icons.email_outlined), // CAMPO NUEVO
                    const SizedBox(height: 15),
                    _campoTexto(_matriculaController, "Matrícula", Icons.numbers, esNumerico: true),
                    const SizedBox(height: 15),
                    _campoTexto(_passwordController, "Contraseña", Icons.lock_outline, esPassword: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B009),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _registrarUsuario,
                      child: const Text("CREAR CUENTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String hint, IconData icon, {bool esPassword = false, bool esNumerico = false}) {
    return TextField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: esNumerico ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E40AF)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }
}