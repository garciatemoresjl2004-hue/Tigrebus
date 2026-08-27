import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para la conexión real

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  // Controlador para el campo de texto
  final TextEditingController _emailController = TextEditingController();

  Future<void> _enviarCorreoRecuperacion() async {
    // 1. Validar que no esté vacío
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa un correo electrónico válido."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar círculo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF3B009))),
    );

    try {
      // 2. PETICIÓN REAL A FIREBASE
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Quitar carga

      // 3. Éxito
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("¡Correo Enviado!"),
          content: const Text(
            "Hemos enviado un enlace de recuperación a tu correo universitario. Por favor, revisa tu bandeja de entrada y SPAM.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Cierra diálogo
                Navigator.pop(context); // Regresa al Login
              },
              child: const Text("ENTENDIDO", style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Quitar carga

      String errorMsg = "Ocurrió un error al enviar el correo.";
      if (e.code == 'user-not-found') errorMsg = "Este correo no está registrado en TigreBus.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
              const SizedBox(height: 120),
              // Icono de candado con estilo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Recuperar Acceso",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  "Ingresa tu correo universitario y te enviaremos un enlace para restablecer tu contraseña.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),

              // Contenedor blanco (Formulario)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                // Ajuste de altura según la pantalla
                height: MediaQuery.of(context).size.height - 350,
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "ejemplo@uanl.edu.mx",
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E40AF)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B009),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                      ),
                      onPressed: _enviarCorreoRecuperacion,
                      child: const Text(
                        "ENVIAR INSTRUCCIONES",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}