import 'package:flutter/material.dart';

/// Vista para el estado vacío (cuando no hay tareas o registros que mostrar).
///
/// Ofrece un mensaje claro y amigable al usuario con un ícono descriptivo.
class EmptyView extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final Widget? accion;

  const EmptyView({
    super.key,
    this.mensaje = 'No hay tareas disponibles por ahora.',
    this.icono = Icons.inbox_outlined,
    this.accion,
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
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
