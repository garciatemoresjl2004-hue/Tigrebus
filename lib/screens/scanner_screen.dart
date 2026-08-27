import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = true;

  // Obtenemos la fecha de hoy para validar el boleto al instante
  String get _fechaHoy => "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  // Función para procesar la información del QR
  Future<void> _validarBoleto(String code) async {
    setState(() => _isScanning = false); // Pausamos el escáner

    try {
      // 1. Descomponer la trama: TIGREBUS|uid|asiento|ticketId|fecha
      List<String> datos = code.split('|');

      if (datos.length < 5 || datos[0] != "TIGREBUS") {
        _mostrarResultado(context, "QR INVÁLIDO", "Este código no pertenece a TigreBus.", Colors.red);
        return;
      }

      String uid = datos[1];
      String asiento = datos[2];
      String ticketId = datos[3];
      String fechaBoleto = datos[4];

      // 2. Validación de Fecha (No dejar subir si el boleto es de otro día)
      if (fechaBoleto != _fechaHoy) {
        _mostrarResultado(context, "BOLETO EXPIRADO", "Este boleto es de la fecha: $fechaBoleto", Colors.orange);
        return;
      }

      // 3. Consultar en Firebase si el boleto ya fue usado
      var doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('MisBoletos')
          .doc(ticketId)
          .get();

      if (!doc.exists) {
        _mostrarResultado(context, "NO ENCONTRADO", "El boleto no existe en el sistema.", Colors.red);
      } else if (doc['estado'] == 'usado') {
        _mostrarResultado(context, "YA USADO", "Este boleto ya fue escaneado anteriormente.", Colors.redAccent);
      } else {
        // 4. TODO CORRECTO: Marcar como usado y dar acceso
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('MisBoletos')
            .doc(ticketId)
            .update({'estado': 'usado'});

        _mostrarResultado(context, "¡ACCESO CONCEDIDO!", "Ruta: ${doc['ruta']}\nAsiento: #$asiento", Colors.green);
      }
    } catch (e) {
      _mostrarResultado(context, "ERROR TÉCNICO", "No se pudo conectar con la base de datos.", Colors.black);
    }
  }

  void _mostrarResultado(BuildContext context, String titulo, String mensaje, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: color,
        title: Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanning = true); // Reactivamos el escáner
            },
            child: const Text("CONTINUAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validador de Pasajes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // CÁMARA DEL ESCÁNER
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _validarBoleto(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // MASCARA VISUAL (EL CUADRO DE ENFOQUE)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: _isScanning ? Colors.white : Colors.green, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  "Enfoque el código QR del alumno",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}