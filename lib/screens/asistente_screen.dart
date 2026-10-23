import 'package:flutter/material.dart';

import '../widgets/empty_view.dart';

/// Pantalla base para el asistente de IA conectado al servidor propio (Paso 6).
class AsistenteScreen extends StatelessWidget {
  const AsistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Asistente AlToque'),
      ),
      body: const EmptyView(
        icono: Icons.smart_toy_outlined,
        mensaje: 'En esta sección podrás interactuar con el asistente de IA para solicitar recomendaciones de priorización y planificar tu jornada.',
      ),
    );
  }
}
