import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionUsuariosScreen extends StatelessWidget {
  const GestionUsuariosScreen({super.key});

  Future<void> _eliminarUsuario(BuildContext context, String id, String nombre) async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Usuario"),
        content: Text("¿Estás seguro de eliminar a $nombre? Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('Usuarios').doc(id).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuario eliminado exitosamente")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF), // Azul FIME
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay usuarios registrados."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userDoc = snapshot.data!.docs[index];

              // 1. Convertimos los datos a un Mapa Seguro
              Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

              // 2. Extraemos con cuidado usando containsKey
              String rol = data.containsKey('rol') ? data['rol'] : 'alumno';
              String nombre = data.containsKey('nombre') ? data['nombre'] : 'Usuario sin nombre';
              String matricula = data.containsKey('matricula') ? data['matricula'] : 'N/A';
              String email = data.containsKey('email') ? data['email'] : 'Sin correo registrado';

              // Evitamos que el admin se elimine a sí mismo viéndose en la lista
              if (rol == 'admin') return const SizedBox();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
                    child: const Icon(Icons.person, color: Color(0xFF1E40AF)),
                  ),
                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Matrícula: $matricula\n$email"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _eliminarUsuario(context, userDoc.id, nombre),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}