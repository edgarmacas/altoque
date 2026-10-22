import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'utils/reporte_errores.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Conecta el capturador global de errores para sustituir la pantalla roja y sanitizar logs
  ReporteErrores.instalar();

  runApp(const AlToqueApp());
}

/// Aplicación principal AlToque.
class AlToqueApp extends StatelessWidget {
  const AlToqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AlToque — Tareas Personales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Azul institucional enérgico
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AlToque 🇪🇨'),
        ),
        body: const Center(
          child: Text(
            '¡Bienvenido a AlToque!\nProductividad sin rodeos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
