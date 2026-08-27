import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- AGREGAR

class RutasHorariosScreen extends StatelessWidget {
  const RutasHorariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Información TigreBus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1E40AF),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Color(0xFFF3B009),
            labelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: "Disponibilidad"),
              Tab(icon: Icon(Icons.route), text: "Recorridos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabHorarios(),
            _TabRecorridos(),
          ],
        ),
      ),
    );
  }
}

class _TabHorarios extends StatelessWidget {
  const _TabHorarios();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Rutas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              const Text("Rutas en Tiempo Real",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
              const SizedBox(height: 10),

              // MAPEO DINÁMICO DESDE FIREBASE
              ...snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                bool estaActiva = data['activa'] ?? true;

                return Card(
                  elevation: estaActiva ? 3 : 0,
                  color: estaActiva ? Colors.white : Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Icon(
                        Icons.directions_bus,
                        color: estaActiva ? const Color(0xFFF3B009) : Colors.grey
                    ),
                    title: Text(doc.id,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: estaActiva ? const Color(0xFF1E40AF) : Colors.grey
                        )),
                    subtitle: Text(estaActiva
                        ? "Salida: ${data['horario'] ?? 'N/A'}"
                        : "⚠️ RUTA EN MANTENIMIENTO"),
                    trailing: estaActiva
                        ? const Icon(Icons.chevron_right)
                        : const Icon(Icons.build_circle, color: Colors.orange),
                    onTap: () {
                      if (estaActiva) {
                        // Aquí navegarías a la selección de asientos
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => AsientosScreen(rutaId: doc.id)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Esta unidad se encuentra en mantenimiento. Por favor elige otra."),
                              backgroundColor: Colors.orange,
                            )
                        );
                      }
                    },
                  ),
                );
              }),

              const Divider(height: 40),
              const Text("Horarios Generales de Apoyo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              // Mantenemos tus cards estáticas de información abajo como referencia
              _infoCard("Información de Salidas", "Ciudad Universitaria", [
                "A Mederos: 6:15, 7:50, 10:15, 12:15, 14:00, 16:00, 18:10 hrs",
                "A Salud y Agropecuarias: 6:15 hrs",
              ]),
            ],
          );
        }
    );
  }

  Widget _infoCard(String titulo, String subtitulo, List<String> puntos) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
            Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(),
            ...puntos.map((p) => ListTile(dense: true, leading: const Icon(Icons.access_time, size: 18, color: Color(0xFFF3B009)), title: Text(p))),
          ],
        ),
      ),
    );
  }
}

// ... EL RESTO DE TU CLASE _TabRecorridos SE MANTIENE IGUAL ...
class _TabRecorridos extends StatelessWidget {
  const _TabRecorridos();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        _routeExpansion("Campus Mederos (6:45 - 21:15)", [
          "1. Walmart Av. Eugenio Garza Sada", "2. Caseta vigilancia", "3. Banco Banorte", "4. Fac. Ciencias Políticas", "5. Fac. Ciencias de la Comunicación", "6. Fac. Artes Escénicas (regreso)", "7. Fac. Economía (regreso)"
        ]),
        _routeExpansion("Campus Ciencias de la Salud", [
          "1. Estación Metro Hospital", "2. Prepa 15 Unidad Madero", "3. Fac. Medicina", "4. Prepa Técnica Médica", "5. Fac. Enfermería", "6. Fac. Psicología", "7. Plaza (Hermosillo y Chihuahua)", "8. Banco Banregio"
        ]),
        _routeExpansion("Campus Ciencias Agropecuarias", [
          "1. Estación Metro Sendero", "2. Carretera Colombia y Juárez", "3. Carretera Colombia y Concordia", "4. Biblioteca de Ciencias Agropecuarias", "5. Fac. Veterinaria", "6. Lácteos", "7. Fac. Agronomía", "* Salida Metro Cuauhtémoc: 6:30 hrs"
        ]),
        _routeExpansion("Campus Ciudad Universitaria (6:20 - 21:15)", [
          "1. FACPYA", "2. Ciencias Biológicas (Unidad B)", "3. Centro Acuático", "4. Gimnasio Cayetano Garza", "5. Gimnasio Raymundo Chico Rivera", "6. Ciencias Biológicas (Unidad A)", "7. FIME", "8. Sorteos y Fac. Arquitectura", "* Salidas a Civil desde FIME: 8:00, 11:00, 14:00 y 16:00"
        ]),
      ],
    );
  }

  Widget _routeExpansion(String titulo, List<String> paradas) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
        leading: const Icon(Icons.location_on, color: Color(0xFFF3B009)),
        children: paradas.map((p) => ListTile(title: Text(p), leading: const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey))).toList(),
      ),
    );
  }
}