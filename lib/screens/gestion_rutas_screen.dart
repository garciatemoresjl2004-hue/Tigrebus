import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionRutasScreen extends StatefulWidget {
  const GestionRutasScreen({super.key});

  @override
  State<GestionRutasScreen> createState() => _GestionRutasScreenState();
}

class _GestionRutasScreenState extends State<GestionRutasScreen> {
  final TextEditingController _nombreRutaController = TextEditingController();
  final TextEditingController _choferController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _numUnidadController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();

  Future<void> _agregarRuta() async {
    String nombreRuta = _nombreRutaController.text.trim();
    if (nombreRuta.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('Rutas').doc(nombreRuta).set({
        'nombre': nombreRuta,
        'chofer': _choferController.text.trim(),
        'placa': _placaController.text.trim(),
        'num_unidad': _numUnidadController.text.trim(),
        'horario': _horarioController.text.trim(),
        'asientos_ocupados': [],
        'capacidad': 40,
        'activa': true, // <--- NUEVO: Por defecto las rutas nacen activas
        'creada_el': FieldValue.serverTimestamp(),
      });

      _limpiarControladores();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ruta agregada"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- NUEVA FUNCIÓN PARA MANTENIMIENTO ---
  Future<void> _alternarMantenimiento(String idRuta, bool estadoActual) async {
    await FirebaseFirestore.instance.collection('Rutas').doc(idRuta).update({
      'activa': !estadoActual,
    });
  }

  void _limpiarControladores() {
    _nombreRutaController.clear();
    _choferController.clear();
    _placaController.clear();
    _numUnidadController.clear();
    _horarioController.clear();
  }

  Future<void> _eliminarRuta(String idRuta) async {
    await FirebaseFirestore.instance.collection('Rutas').doc(idRuta).delete();
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nueva Unidad"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campoTexto(_nombreRutaController, "Nombre de Ruta", Icons.map),
              _campoTexto(_choferController, "Nombre del Chofer", Icons.person),
              _campoTexto(_placaController, "Matrícula / Placa", Icons.subtitles),
              _campoTexto(_numUnidadController, "Número de Eco", Icons.numbers),
              _campoTexto(_horarioController, "Horario de Salida", Icons.access_time),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3B009)),
            onPressed: _agregarRuta,
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E40AF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Rutas"),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Rutas').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No hay rutas registradas."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var rutaDoc = snapshot.data!.docs[index];
              Map<String, dynamic> data = rutaDoc.data() as Map<String, dynamic>;

              String unidad = data['num_unidad'] ?? 'N/A';
              String chofer = data['chofer'] ?? 'N/A';
              String placa = data['placa'] ?? 'N/A';
              String horario = data['horario'] ?? 'N/A';
              List asientos = data['asientos_ocupados'] ?? [];
              bool estaActiva = data['activa'] ?? true; // <--- LEEMOS EL ESTADO

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                // SI ESTÁ EN MANTENIMIENTO, PONEMOS EL BORDE GRIS
                color: estaActiva ? Colors.white : Colors.grey.shade100,
                child: ExpansionTile(
                  leading: Icon(
                      Icons.directions_bus,
                      color: estaActiva ? const Color(0xFF1E40AF) : Colors.grey
                  ),
                  title: Row(
                    children: [
                      Text(rutaDoc.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (!estaActiva)
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Chip(label: Text("TALLER", style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.orange, padding: EdgeInsets.zero,),
                        )
                    ],
                  ),
                  subtitle: Text("Eco: $unidad - Chofer: $chofer"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          _infoRow(Icons.subtitles, "Placas", placa),
                          _infoRow(Icons.access_time, "Salida", horario),
                          _infoRow(Icons.airline_seat_recline_normal, "Ocupados", "${asientos.length} / 40"),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // --- BOTÓN MANTENIMIENTO ---
                              TextButton.icon(
                                onPressed: () => _alternarMantenimiento(rutaDoc.id, estaActiva),
                                icon: Icon(
                                    estaActiva ? Icons.build : Icons.play_circle_fill,
                                    color: estaActiva ? Colors.orange : Colors.green
                                ),
                                label: Text(
                                    estaActiva ? "Mantenimiento" : "Activar",
                                    style: TextStyle(color: estaActiva ? Colors.orange : Colors.green)
                                ),
                              ),
                              // --- BOTÓN ELIMINAR ---
                              TextButton.icon(
                                onPressed: () => _eliminarRuta(rutaDoc.id),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF3B009),
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}