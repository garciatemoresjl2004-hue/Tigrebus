import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_generator_screen.dart';

class MisQRScreen extends StatelessWidget {
  const MisQRScreen({super.key});

  // Función para obtener la fecha de hoy y comparar
  String get _fechaHoy => "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  Future<void> _confirmarUso(BuildContext context, DocumentSnapshot boleto) async {
    // 1. Verificamos si el boleto es de hoy antes de siquiera preguntar
    if (boleto['fecha'] != _fechaHoy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este boleto expiró. Solo puedes usar boletos del día actual."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Si es de hoy, mostramos tu diálogo de confirmación
    bool? confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Activar Boleto?",
            style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold)),
        content: const Text("Al activarlo, tendrás 15 minutos para abordar la unidad y mostrar este código. ¿Deseas utilizarlo ahora?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Más tarde")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3B009)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sí, Utilizar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => QrGeneratorScreen(
            asiento: boleto['asiento'],
            ruta: boleto['ruta'],
            ticketId: boleto.id,
            fecha: boleto['fecha'], // <--- IMPORTANTE: Pasamos la fecha al generador
          )
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Boletos Guardados",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('MisBoletos')
            .where('estado', isEqualTo: 'valido')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No tienes boletos pendientes de uso.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var boleto = snapshot.data!.docs[index];
              bool esDeHoy = boleto['fecha'] == _fechaHoy;

              return Card(
                elevation: esDeHoy ? 3 : 0,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                // Si no es de hoy, lo ponemos un poco más opaco para que se note
                color: esDeHoy ? Colors.white : Colors.grey.shade100,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: Icon(
                      Icons.qr_code_2,
                      color: esDeHoy ? const Color(0xFF1E40AF) : Colors.grey,
                      size: 40
                  ),
                  title: Text(
                      "Asiento ${boleto['asiento']} - ${boleto['ruta']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: esDeHoy ? Colors.black : Colors.grey
                      )
                  ),
                  subtitle: Text(
                      esDeHoy
                          ? "Toca para activar el pase de abordar"
                          : "EXPIRADO (${boleto['fecha']})",
                      style: TextStyle(color: esDeHoy ? Colors.green : Colors.red)
                  ),
                  onTap: () => _confirmarUso(context, boleto),
                ),
              );
            },
          );
        },
      ),
    );
  }
}