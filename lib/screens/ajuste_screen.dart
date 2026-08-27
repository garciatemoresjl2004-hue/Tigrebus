import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Asegúrate de que themeNotifier esté aquí
import 'login_screen.dart';

// Cambiamos el nombre a singular para que coincida con la navegación del mapa
class AjusteScreen extends StatefulWidget {
  const AjusteScreen({super.key});

  @override
  State<AjusteScreen> createState() => _AjusteScreenState();
}

class _AjusteScreenState extends State<AjusteScreen> {
  Future<void> _abrirSoporte() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'adminstrador6@gmail.com',
      query: 'subject=Soporte TigreBus - FIME',
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        throw Exception('No se pudo abrir el correo');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No se encontró app de correo."),
            backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ValueListenableBuilder si themeNotifier es un ValueNotifier
    // o simplemente leemos el valor si el estado se actualiza externamente
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
              "Apariencia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF1E40AF)
              ),
              title: const Text("Modo Oscuro"),
              activeThumbColor: const Color(0xFFF3B009),
              value: isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
              "Ayuda y Soporte",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.support_agent, color: Color(0xFF1E40AF)),
              title: const Text("Contactar Soporte"),
              subtitle: const Text("Envíanos un correo directamente"),
              onTap: _abrirSoporte,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
                "CERRAR SESIÓN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            onPressed: () async {
              // Diálogo de confirmación (Opcional pero recomendado)
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}