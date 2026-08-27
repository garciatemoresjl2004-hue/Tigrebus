import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Historial de Viajes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF), // Azul FIME
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // CONSULTA SIMPLIFICADA: No requiere índices manuales en Firebase
        stream: FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('MisBoletos')
            .where('estado', isEqualTo: 'usado')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Formateamos la fecha de forma segura
              String fechaCompleta = data['fecha']?.toString() ?? "Fecha no disponible";
              String fechaCorta = fechaCompleta.length > 10
                  ? fechaCompleta.substring(0, 10) : fechaCompleta;
              String horaCorta = fechaCompleta.length > 16
                  ? fechaCompleta.substring(11, 16) : "";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(Icons.history, color: Color(0xFF1E40AF)),
                  ),
                  title: Text("Asiento ${data['asiento']} - ${data['ruta']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Viaje realizado el $fechaCorta a las $horaCorta"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          const Text("No tienes viajes registrados aún.",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 15),
            const Text("Error al cargar datos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Asegúrate de que el estado en Firebase sea 'usado' (minúsculas).",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}