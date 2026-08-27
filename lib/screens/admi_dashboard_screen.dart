import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'gestion_rutas_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'scanner_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Panel de Control", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _cerrarSesion)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenido, Administrador", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
            const SizedBox(height: 10),
            const Text("¿Qué deseas gestionar hoy?", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),

            _menuCard(
              context,
              titulo: "Gestión de Rutas",
              subtitulo: "Agregar, editar o eliminar unidades",
              icono: Icons.directions_bus,
              color: const Color(0xFFF3B009),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GestionRutasScreen())),
            ),

            _menuCard(
              context,
              titulo: "Gestión de Usuarios",
              subtitulo: "Ver alumnos y control de acceso",
              icono: Icons.people,
              color: const Color(0xFF1E40AF),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GestionUsuariosScreen())),
            ),

            _menuCard(
              context,
              titulo: "Escanear Pasajes QR",
              subtitulo: "Validar abordaje de alumnos",
              icono: Icons.qr_code_scanner,
              color: Colors.green.shade700,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, {required String titulo, required String subtitulo, required IconData icono, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icono, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(subtitulo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey)
            ],
          ),
        ),
      ),
    );
  }
}