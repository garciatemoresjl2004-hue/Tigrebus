import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importaciones de todas tus pantallas del proyecto Tigrebus
import 'historial_screen.dart';
import 'asientos_screen.dart';
import 'perfil_screen.dart';
import 'ajuste_screen.dart';
import 'mis_qr_screen.dart';
import 'qr_generator_screen.dart';
import 'rutas_horarios_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Función para mostrar el menú de rutas que consume de Firebase
  void _mostrarMenuRutas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)
                )
            ),
            const SizedBox(height: 15),
            const Text(
                "Selecciona tu Ruta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Rutas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()
                );

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var rutaDoc = snapshot.data!.docs[index];
                    var data = rutaDoc.data() as Map<String, dynamic>;

                    // --- NUEVA LÓGICA DE ACTIVACIÓN ---
                    bool estaActiva = data['activa'] ?? true;

                    return ListTile(
                      // Cambia color si está desactivada
                      leading: Icon(
                          Icons.directions_bus,
                          color: estaActiva ? const Color(0xFFF3B009) : Colors.grey
                      ),
                      title: Text(
                          rutaDoc.id,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: estaActiva ? Colors.black : Colors.grey
                          )
                      ),
                      subtitle: Text(
                          estaActiva
                              ? "Unidad: ${data['num_unidad'] ?? 'N/A'} - Horario: ${data['horario'] ?? 'Ver detalles'}"
                              : "⚠️ RUTA EN MANTENIMIENTO",
                          style: TextStyle(
                              color: estaActiva ? Colors.black54 : Colors.orange.shade700,
                              fontWeight: estaActiva ? FontWeight.normal : FontWeight.bold
                          )
                      ),
                      trailing: Icon(
                          estaActiva ? Icons.arrow_forward_ios : Icons.build_circle,
                          size: 16,
                          color: estaActiva ? Colors.grey : Colors.orange
                      ),
                      onTap: () {
                        // --- BLOQUEO DE NAVEGACIÓN ---
                        if (estaActiva) {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AsientosScreen(rutaId: rutaDoc.id)
                          ));
                        } else {
                          // Aviso al alumno
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Esta ruta no está disponible por el momento."),
                                backgroundColor: Colors.orange,
                              )
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E40AF)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.directions_bus, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                      "TigreBus FIME",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined, color: Color(0xFF1E40AF)),
              title: const Text('Rutas y Horarios', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RutasHorariosScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1E40AF)),
              title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF1E40AF)),
              title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AjusteScreen())
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("TigreBus en Vivo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF).withAlpha(230),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_2),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QrGeneratorScreen()))
          ),
          IconButton(
              icon: const Icon(Icons.confirmation_number),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MisQRScreen()))
          ),
          IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistorialScreen()))
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
                initialCenter: LatLng(25.7256, -100.3138), // Coordenadas de FIME
                initialZoom: 16
            ),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fime.tigrebus'
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            left: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B009), // Oro FIME
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              onPressed: () => _mostrarMenuRutas(context),
              icon: const Icon(Icons.directions_bus_filled, color: Colors.white),
              label: const Text(
                  "VER RUTAS DISPONIBLES",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}