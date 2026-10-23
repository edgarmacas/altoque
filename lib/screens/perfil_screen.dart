import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/tareas_controller.dart';

/// Pantalla de perfil de usuario y métricas generales de productividad.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Widget _buildTarjetaMetrica({
    required BuildContext context,
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
            Text(
              valor,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final tareasCtrl = Get.find<TareasController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mi cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de información del usuario
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 30,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Usuario autenticado',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Obx(() => Text(
                                      auth.emailActual.value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resumen de métricas
                  Text(
                    'Resumen de actividades',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                        children: [
                          _buildTarjetaMetrica(
                            context: context,
                            titulo: 'Total de tareas',
                            valor: '${tareasCtrl.totalTareas}',
                            icono: Icons.format_list_bulleted_rounded,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 8),
                          _buildTarjetaMetrica(
                            context: context,
                            titulo: 'Tareas pendientes',
                            valor: '${tareasCtrl.totalPendientes}',
                            icono: Icons.pending_actions_rounded,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 8),
                          _buildTarjetaMetrica(
                            context: context,
                            titulo: 'Tareas en progreso',
                            valor: '${tareasCtrl.totalEnProgreso}',
                            icono: Icons.timelapse_rounded,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(height: 8),
                          _buildTarjetaMetrica(
                            context: context,
                            titulo: 'Tareas completadas',
                            valor: '${tareasCtrl.totalCompletadas}',
                            icono: Icons.check_circle_outline_rounded,
                            color: Colors.green.shade700,
                          ),
                        ],
                      )),
                  const SizedBox(height: 28),

                  // Botón cerrar sesión
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (d) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(d),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(d);
                                auth.cerrarSesion();
                              },
                              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                              child: const Text('Salir'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
