import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'admi_dashboard_screen.dart';
import 'registro_screen.dart'; // <--- YA ENCENDIDO
import 'recuperar_password_screen.dart'; // <--- YA ENCENDIDO

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa correo y contraseña"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (email == 'adminstrador6@gmail.com') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen())
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen())
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = "Error al iniciar sesión";
      if (e.code == 'user-not-found') errorMsg = "No existe un usuario con ese correo";
      if (e.code == 'wrong-password') errorMsg = "Contraseña incorrecta";
      if (e.code == 'invalid-email') errorMsg = "El formato del correo es inválido";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                const Spacer(),
                const LogoTigreBus(),
                const SizedBox(height: 20),
                const Text(
                  "TigreBus",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const Text(
                  "UANL - FIME",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Correo Universitario",
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E40AF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF1E40AF)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // <--- NAVEGACIÓN A RECUPERAR CONTRASEÑA ENCENDIDA
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RecuperarPasswordScreen()));
                          },
                          child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFF1E40AF))),
                        ),
                      ),

                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3B009),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("INGRESAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          side: const BorderSide(color: Color(0xFF1E40AF), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          // <--- NAVEGACIÓN A REGISTRO ENCENDIDA
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroScreen()));
                        },
                        child: const Text("CREAR CUENTA", style: TextStyle(color: Color(0xFF1E40AF), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogoTigreBus extends StatelessWidget {
  const LogoTigreBus({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF3B009).withAlpha(100),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFF3B009), Color(0xFFFFD700)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Container(
          width: 135,
          height: 135,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E40AF),
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3B009),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "FIME",
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}