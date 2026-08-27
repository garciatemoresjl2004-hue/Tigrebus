import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

// 1. CREAMOS UN NOTIFICADOR GLOBAL
// Esto es como un "megáfono". Cuando cambie, toda la app lo escuchará.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TigreBusApp());
}

class TigreBusApp extends StatelessWidget {
  const TigreBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. ENVOLVEMOS LA APP PARA QUE ESCUCHE AL MEGÁFONO
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'TigreBus FIME',
          debugShowCheckedModeBanner: false,

          // Tema Claro (Tus colores originales)
          theme: ThemeData(
            primaryColor: const Color(0xFF1E40AF),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E40AF),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          // Tema Oscuro
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF3B009), // Detalles en amarillo tigre
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          // La app decide qué tema usar basándose en el notificador
          themeMode: currentMode,

          home: const LoginScreen(),
        );
      },
    );
  }
}