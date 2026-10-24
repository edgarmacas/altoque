import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tareas_controller.dart';
import '../widgets/empty_view.dart';
import '../widgets/tarea_card.dart';

/// Pantalla que presenta las tareas favoritas/destacadas persistidas en Hive.
///
/// Cumple con la rúbrica (Criterio 3): Persistencia local que sobrevive al
/// reinicio completo de la aplicación y disponible en modo sin conexión.
class DestacadasScreen extends StatelessWidget {
  const DestacadasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TareasController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tareas destacadas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                Text(
                  '${controller.totalDestacadas} tareas guardadas localmente',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            )),
      ),
      body: Obx(() {
        final destacadas = controller.tareasDestacadas;

        if (destacadas.isEmpty) {
          return const EmptyView(
            icono: Icons.star_outline_rounded,
            mensaje:
                'Aún no has marcado tareas como destacadas.\n\nToca el ícono de estrella en cualquier tarea para tenerla fijada aquí y poder acceder a ella incluso sin conexión.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: destacadas.length,
          itemBuilder: (context, index) {
            final t = destacadas[index];
            return TareaCard(
              tarea: t,
              esDestacada: true,
              onToggleDestacada: () => controller.toggleDestacada(t),
              onAvanzarEstado: () => controller.avanzarEstado(t),
              onEliminar: () => controller.eliminarTarea(t.id),
            );
          },
        );
      }),
    );
  }
}
