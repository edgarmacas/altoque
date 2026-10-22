import 'package:flutter/material.dart';

/// Vista para el estado de error en pantallas y secciones con datos.
///
/// Ofrece un mensaje comprensible para el usuario y un botón de acción para
/// reintentar la operación, evitando que la interfaz sea un callejón sin salida.
class ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;
  final IconData icono;

  const ErrorView({
    super.key,
    required this.mensaje,
    this.onReintentar,
    this.icono = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un inconveniente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje.isNotEmpty ? mensaje : 'No se pudo cargar la información solicitada.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
