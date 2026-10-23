import 'package:flutter/material.dart';

import '../models/tarea.dart';

/// Tarjeta visual que presenta una tarea con su estado, prioridad y acciones.
class TareaCard extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onAvanzarEstado;
  final VoidCallback onEliminar;

  const TareaCard({
    super.key,
    required this.tarea,
    required this.onAvanzarEstado,
    required this.onEliminar,
  });

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  Color _colorPrioridadFondo() {
    switch (tarea.prioridad) {
      case 'alta':
        return const Color(0xFFFFEEF3); // Suave coral
      case 'baja':
        return const Color(0xFFE0F7FA); // Suave turquesa
      case 'media':
      default:
        return Colors.amber.shade50;
    }
  }

  Color _colorPrioridadTexto() {
    switch (tarea.prioridad) {
      case 'alta':
        return const Color(0xFFE11D48); // Coral fuerte
      case 'baja':
        return const Color(0xFF0E8E98); // Turquesa profundo
      case 'media':
      default:
        return Colors.amber.shade900;
    }
  }

  Color _colorEstadoFondo() {
    switch (tarea.estado) {
      case 'completada':
        return Colors.green.shade50;
      case 'en_progreso':
        return Colors.indigo.shade50;
      case 'pendiente':
      default:
        return Colors.grey.shade100;
    }
  }

  Color _colorEstadoTexto() {
    switch (tarea.estado) {
      case 'completada':
        return Colors.green.shade800;
      case 'en_progreso':
        return Colors.indigo.shade800;
      case 'pendiente':
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildBotonAccion() {
    if (tarea.esCompletada) {
      return Icon(
        Icons.check_circle_rounded,
        color: Colors.green.shade700,
        size: 26,
      );
    }
    if (tarea.esEnProgreso) {
      return IconButton(
        icon: Icon(
          Icons.play_circle_outline_rounded,
          color: Colors.indigo.shade600,
          size: 26,
        ),
        tooltip: 'Completar tarea',
        onPressed: onAvanzarEstado,
      );
    }
    return IconButton(
      icon: Icon(
        Icons.radio_button_unchecked_rounded,
        color: Colors.grey.shade500,
        size: 26,
      ),
      tooltip: 'Iniciar tarea (marcar en progreso)',
      onPressed: onAvanzarEstado,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tarea.esCompletada ? Colors.grey.shade200 : Colors.grey.shade300,
        ),
      ),
      color: tarea.esCompletada ? Colors.grey.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBotonAccion(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarea.titulo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: tarea.esCompletada
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: tarea.esCompletada
                              ? Colors.grey.shade500
                              : Colors.grey.shade900,
                        ),
                      ),
                      if (tarea.descripcion != null &&
                          tarea.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tarea.descripcion!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: tarea.esCompletada
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
                  onSelected: (val) {
                    if (val == 'avanzar') onAvanzarEstado();
                    if (val == 'eliminar') onEliminar();
                  },
                  itemBuilder: (context) => [
                    if (!tarea.esCompletada)
                      PopupMenuItem(
                        value: 'avanzar',
                        child: Text(
                          tarea.esPendiente ? 'Iniciar tarea' : 'Completar tarea',
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar tarea', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fila de etiquetas (prioridad, estado, fecha límite)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Badge de prioridad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _colorPrioridadFondo(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Prioridad: ${tarea.etiquetaPrioridad}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _colorPrioridadTexto(),
                    ),
                  ),
                ),

                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _colorEstadoFondo(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tarea.etiquetaEstado,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _colorEstadoTexto(),
                    ),
                  ),
                ),

                // Fecha límite si existe
                if (tarea.fechaLimite != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatearFecha(tarea.fechaLimite!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
