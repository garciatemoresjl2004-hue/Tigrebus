import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class QrGeneratorScreen extends StatefulWidget {
  final int? asiento;
  final String? ruta;
  final String? ticketId;
  final String? fecha; // <--- AGREGAMOS LA FECHA DEL BOLETO

  const QrGeneratorScreen({super.key, this.asiento, this.ruta, this.ticketId, this.fecha});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  Timer? _timer;
  int _segundosRestantes = 15 * 60;

  // Función para obtener la fecha de hoy
  String get _fechaHoy => "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador();
  }

  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() {
          _segundosRestantes--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finalizarBoleto() async {
    if (widget.ticketId != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('MisBoletos')
            .doc(widget.ticketId)
            .update({'estado': 'usado'});
      } catch (e) {
        // Error silencioso
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Boleto finalizado (Guardado en Historial)"), backgroundColor: Colors.green)
    );
  }

  String get _tiempoFormateado {
    int minutos = _segundosRestantes ~/ 60;
    int segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // LÓGICA DE EXPIRACIÓN POR FECHA O TIEMPO
    bool fechaExpirada = widget.fecha != null && widget.fecha != _fechaHoy;
    bool tiempoAgotado = _segundosRestantes == 0;
    bool esInvalido = tiempoAgotado || fechaExpirada;

    // Agregamos la fecha a la trama del QR para que el escáner del chofer también la valide
    final String qrData = "TIGREBUS|$uid|${widget.asiento ?? '0'}|${widget.ticketId ?? 'GENERICO'}|${widget.fecha ?? _fechaHoy}";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Pase de Abordaje", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E40AF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // CINTA DE ESTADO
            Container(
              width: double.infinity,
              color: esInvalido ? Colors.red : Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(esInvalido ? Icons.error_outline : Icons.timer, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                      fechaExpirada
                          ? "BOLETO DE OTRA FECHA (INVÁLIDO)"
                          : (tiempoAgotado ? "TIEMPO AGOTADO" : "Válido por: $_tiempoFormateado"),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ],
              ),
            ),

            const Spacer(),

            // TARJETA CENTRAL
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: esInvalido ? Colors.red : const Color(0xFF1E40AF), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Text(widget.ruta ?? "Ruta General", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                  const SizedBox(height: 5),
                  Text("Asiento ${widget.asiento ?? 'N/A'}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF3B009))),
                  Text("Fecha: ${widget.fecha ?? _fechaHoy}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 30, thickness: 1.5, color: Colors.grey),

                  // Código QR
                  Opacity(
                    opacity: esInvalido ? 0.2 : 1.0,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220.0,
                      foregroundColor: esInvalido ? Colors.grey : const Color(0xFF1E40AF),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Text(
                      esInvalido ? "Pase Inválido" : "Muestra este código al chofer",
                      style: TextStyle(color: esInvalido ? Colors.red : Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BOTÓN DE CIERRE
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton.icon(
                onPressed: _finalizarBoleto,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text("Finalizar y Salir", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: esInvalido ? Colors.grey : Colors.redAccent,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}