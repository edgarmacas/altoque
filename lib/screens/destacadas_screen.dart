import 'package:flutter/material.dart';

import '../widgets/empty_view.dart';

/// Pantalla base para las tareas destacadas / favoritas persistidas con Hive (Paso 5).
class DestacadasScreen extends StatelessWidget {
  const DestacadasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tareas destacadas'),
      ),
      body: const EmptyView(
        icono: Icons.star_outline_rounded,
        mensaje: 'En esta sección podrás guardar y consultar tus tareas favoritas en Hive para acceder a ellas incluso sin conexión a internet.',
      ),
    );
  }
}
