import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tareas_controller.dart';

/// Pantalla con formulario para registrar una nueva tarea personal.
class TareaFormScreen extends StatefulWidget {
  const TareaFormScreen({super.key});

  @override
  State<TareaFormScreen> createState() => _TareaFormScreenState();
}

class _TareaFormScreenState extends State<TareaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _prioridad = 'media';
  bool _guardando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar(TareasController controller) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final exito = await controller.crearTarea(
      titulo: _tituloCtrl.text,
      prioridad: _prioridad,
      descripcion: _descripcionCtrl.text.isEmpty ? null : _descripcionCtrl.text,
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      Get.back();
      Get.snackbar(
        'Tarea creada',
        'La tarea ha sido registrada exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TareasController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Detalles de la tarea',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completa la información para organizar tu actividad',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Título',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _tituloCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej. Renovar documento de identidad',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Ingresa un título para la tarea';
                            }
                            if (v.trim().length < 3) {
                              return 'Debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Descripción
                        Text(
                          'Descripción (opcional)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descripcionCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Detalles adicionales o notas...',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Selector de Prioridad
                        Text(
                          'Nivel de prioridad',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'baja',
                              label: Text('Baja'),
                              icon: Icon(Icons.arrow_downward, size: 16),
                            ),
                            ButtonSegment(
                              value: 'media',
                              label: Text('Media'),
                              icon: Icon(Icons.remove, size: 16),
                            ),
                            ButtonSegment(
                              value: 'alta',
                              label: Text('Alta'),
                              icon: Icon(Icons.arrow_upward, size: 16),
                            ),
                          ],
                          selected: {_prioridad},
                          onSelectionChanged: (nuevaSeleccion) {
                            setState(() => _prioridad = nuevaSeleccion.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nota: El sistema permite un máximo de 2 tareas de prioridad alta abiertas simultáneamente.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Botón Guardar
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _guardando ? null : () => _guardar(controller),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _guardando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Guardar tarea',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
