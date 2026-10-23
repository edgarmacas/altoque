import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/tareas_controller.dart';
import '../models/tarea.dart';
import '../utils/estado_carga.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/tarea_card.dart';
import 'tarea_form_screen.dart';

/// Pantalla principal de AlToque: Listado de tareas con filtros, estados y acciones.
class TareasScreen extends StatelessWidget {
  const TareasScreen({super.key});

  void _confirmarEliminar(BuildContext context, TareasController controller, Tarea t) {
    showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de que deseas eliminar permanentemente "${t.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(dialogo, true);
              controller.eliminarTarea(t.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(TareasController controller) {
    return Obx(() {
      final actual = controller.filtroEstado.value;
      return Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _chipFiltro(
              label: 'Todas (${controller.totalTareas})',
              seleccionado: actual == 'todos',
              onSelected: () => controller.cambiarFiltroEstado('todos'),
            ),
            const SizedBox(width: 8),
            _chipFiltro(
              label: 'Pendientes (${controller.totalPendientes})',
              seleccionado: actual == 'pendiente',
              onSelected: () => controller.cambiarFiltroEstado('pendiente'),
            ),
            const SizedBox(width: 8),
            _chipFiltro(
              label: 'En progreso (${controller.totalEnProgreso})',
              seleccionado: actual == 'en_progreso',
              onSelected: () => controller.cambiarFiltroEstado('en_progreso'),
            ),
            const SizedBox(width: 8),
            _chipFiltro(
              label: 'Completadas (${controller.totalCompletadas})',
              seleccionado: actual == 'completada',
              onSelected: () => controller.cambiarFiltroEstado('completada'),
            ),
          ],
        ),
      );
    });
  }

  Widget _chipFiltro({
    required String label,
    required bool seleccionado,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: const Color(0xFF1DCED8).withValues(alpha: 0.18),
      side: BorderSide(
        color: seleccionado ? const Color(0xFF0E8E98) : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
        color: seleccionado ? const Color(0xFF0E8E98) : Colors.grey.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final controller = Get.put<TareasController>(TareasController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AlToque', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                Text(
                  '${controller.totalTareas} tareas registradas',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar tareas',
            onPressed: controller.cargarTareas,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (val) {
              if (val == 'logout') auth.cerrarSesion();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  auth.emailActual.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const TareaFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFiltros(controller),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Obx(() {
              if (controller.estado.value == EstadoCarga.cargando) {
                return const LoadingView(mensaje: 'Consultando tus tareas...');
              }

              if (controller.estado.value == EstadoCarga.error) {
                return ErrorView(
                  mensaje: controller.mensajeError.value,
                  onReintentar: controller.cargarTareas,
                );
              }

              if (controller.tareas.isEmpty) {
                return EmptyView(
                  mensaje: 'Aún no registras tareas en tu lista.',
                  accion: FilledButton.icon(
                    onPressed: () => Get.to(() => const TareaFormScreen()),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera tarea'),
                  ),
                );
              }

              final filtradas = controller.tareasFiltradas;
              if (filtradas.isEmpty) {
                return const EmptyView(
                  mensaje: 'No hay tareas que coincidan con el filtro seleccionado.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.cargarTareas,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final t = filtradas[index];
                    return TareaCard(
                      tarea: t,
                      onAvanzarEstado: () => controller.avanzarEstado(t),
                      onEliminar: () => _confirmarEliminar(context, controller, t),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
