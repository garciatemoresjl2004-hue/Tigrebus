import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_generator_screen.dart';

class AsientosScreen extends StatefulWidget {
  final String rutaId;
  const AsientosScreen({super.key, required this.rutaId});

  @override
  State<AsientosScreen> createState() => _AsientosScreenState();
}

class _AsientosScreenState extends State<AsientosScreen> {

  // Función para obtener la fecha de hoy en formato simple (AAAA-MM-DD)
  String get _fechaHoy => "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  void _reservarAsiento(BuildContext context, int numeroAsiento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildUrbaniMenu(context, ctx, numeroAsiento),
    );
  }

  Widget _buildUrbaniMenu(BuildContext contextPrincipal, BuildContext contextModal, int num) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(color: Color(0xFF1E40AF), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: const Center(child: Text("Confirmar Reserva", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text("Ruta: ${widget.rutaId}\nAsiento #$num\nFecha: $_fechaHoy",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
          Row(
            children: [
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3B009), padding: const EdgeInsets.all(20)),
                onPressed: () => _procesar(contextPrincipal, contextModal, num, false),
                child: const Text("GUARDAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E40AF), padding: const EdgeInsets.all(20)),
                onPressed: () => _procesar(contextPrincipal, contextModal, num, true),
                child: const Text("USAR AHORA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _procesar(BuildContext cp, BuildContext cm, int num, bool usar) async {
    Navigator.pop(cm);
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // 1. Guardar la reserva global (Esto es lo que verán todos los usuarios hoy)
    await FirebaseFirestore.instance.collection('Reservas').add({
      'asiento': num,
      'rutaId': widget.rutaId,
      'fecha': _fechaHoy, // <--- CLAVE PARA EL REINICIO DIARIO
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Guardar el boleto personal del usuario
    DocumentReference doc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).collection('MisBoletos').add({
      'asiento': num,
      'ruta': widget.rutaId,
      'fecha': _fechaHoy,
      'fecha_completa': DateTime.now().toIso8601String(),
      'estado': 'valido',
    });

    if (!cp.mounted) return;
    if (usar) {
      Navigator.push(cp, MaterialPageRoute(builder: (context) => QrGeneratorScreen(asiento: num, ruta: widget.rutaId, ticketId: doc.id)));
    } else {
      ScaffoldMessenger.of(cp).showSnackBar(const SnackBar(content: Text("Boleto reservado con éxito"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asientos: ${widget.rutaId}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // CAMBIO: Ahora escuchamos la colección de 'Reservas' filtrada por HOY
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Reservas')
            .where('rutaId', isEqualTo: widget.rutaId)
            .where('fecha', isEqualTo: _fechaHoy)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Creamos la lista de asientos ocupados basándonos en las reservas de hoy
          List<int> ocupados = snapshot.data!.docs.map((doc) => doc['asiento'] as int).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15
            ),
            itemCount: 40,
            itemBuilder: (context, index) {
              int num = index + 1;
              if (index % 4 == 2) return const SizedBox(); // Pasillo

              bool estaOcupado = ocupados.contains(num);

              return GestureDetector(
                onTap: estaOcupado ? null : () => _reservarAsiento(context, num),
                child: Container(
                  decoration: BoxDecoration(
                    color: estaOcupado ? Colors.grey.shade400 : Colors.white,
                    border: Border.all(
                        color: estaOcupado ? Colors.grey : const Color(0xFF1E40AF),
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: estaOcupado ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Center(
                      child: Text(
                          "$num",
                          style: TextStyle(
                              color: estaOcupado ? Colors.white : const Color(0xFF1E40AF),
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          )
                      )
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