import 'package:flutter/material.dart';

/// Vista para el estado de carga (indicador de progreso y mensaje).
///
/// Cumple con la regla del curso: ninguna pantalla queda en blanco mientras
/// espera datos del servidor o de almacenamiento local.
class LoadingView extends StatelessWidget {
  final String mensaje;

  const LoadingView({
    super.key,
    this.mensaje = 'Cargando información...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
