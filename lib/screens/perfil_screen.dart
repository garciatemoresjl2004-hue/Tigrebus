import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ID del usuario que tiene la sesión iniciada
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E40AF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: uid == null
          ? const Center(child: Text("Error: No hay sesión activa."))
      // FutureBuilder lee la base de datos una vez al abrir la pantalla
          : FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Usuarios').doc(uid).get(),
        builder: (context, snapshot) {

          // 1. Mientras espera la respuesta de internet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF3B009)));
          }

          // 2. Si hay un error o no existe
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No se encontraron los datos del usuario."));
          }

          // 3. Extraemos los datos del documento
          var datosUsuario = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFF3B009),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Mostramos los datos reales
                Text(
                  datosUsuario['nombre'] ?? 'Sin Nombre',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                ),
                const SizedBox(height: 10),
                _itemPerfil(Icons.numbers, "Matrícula", datosUsuario['matricula'] ?? 'N/A'),
                const SizedBox(height: 10),
                _itemPerfil(Icons.email, "Correo", datosUsuario['email'] ?? 'N/A'),
                const SizedBox(height: 10),
                _itemPerfil(Icons.badge, "Rol", (datosUsuario['rol'] ?? 'estudiante').toUpperCase()),
              ],
            ),
          );
        },
      ),
    );
  }

  // Un pequeño diseño para que se vea limpio
  Widget _itemPerfil(IconData icono, String titulo, String valor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF1E40AF)),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}