import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/mensaje_chat.dart';
import '../services/api_exception.dart';
import '../services/asistente_api_service.dart';
import 'tareas_controller.dart';

/// Controlador GetX para la gestión del chat con el asistente de IA.
///
/// Implementa el flujo conversacional sin exponer secretos en el cliente.
class AsistenteController extends GetxController {
  final AsistenteApiService _apiService;

  final RxList<MensajeChat> mensajes = <MensajeChat>[].obs;
  final RxBool estaCargando = false.obs;
  final RxString mensajeError = ''.obs;
  final TextEditingController inputController = TextEditingController();

  /// Sugerencias rápidas para orientar al usuario en la gestión de sus tareas
  final List<String> sugerencias = const [
    '¿Cuáles tareas debo priorizar hoy?',
    'Dame un resumen de mis tareas pendientes',
    '¿Tengo tareas de prioridad alta sin resolver?',
  ];

  bool get tieneMensajes => mensajes.isNotEmpty;

  AsistenteController({AsistenteApiService? apiService})
      : _apiService = apiService ?? AsistenteApiService();

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  /// Envía la consulta al asistente y agrega la respuesta a la conversación.
  Future<void> enviarMensaje([String? textoOpcional]) async {
    final texto = (textoOpcional ?? inputController.text).trim();
    if (texto.isEmpty || estaCargando.value) return;

    if (textoOpcional == null) {
      inputController.clear();
    }

    mensajeError.value = '';

    // 1. Agregar mensaje del usuario a la lista reactiva
    final msgUsuario = MensajeChat(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      texto: texto,
      esUsuario: true,
    );
    mensajes.add(msgUsuario);

    // 2. Consultar al servicio
    estaCargando.value = true;
    try {
      final respuesta = await _apiService.consultar(texto);
      mensajes.add(respuesta);
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      mensajes.add(MensajeChat(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        texto: 'Error: ${e.mensaje}',
        esUsuario: false,
      ));
    } catch (_) {
      const errorGenerico = 'No se pudo obtener respuesta del asistente. Por favor, reintenta.';
      mensajeError.value = errorGenerico;
      mensajes.add(MensajeChat(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        texto: errorGenerico,
        esUsuario: false,
      ));
    } finally {
      estaCargando.value = false;
    }
  }

  /// Ejecuta una acción sugerida por el asistente previa confirmación de la persona.
  Future<bool> ejecutarAccion(AccionAsistente accion) async {
    if (accion.tipo == 'iniciar_tarea' && accion.tareaId != null) {
      if (Get.isRegistered<TareasController>()) {
        final tareasCtrl = Get.find<TareasController>();
        final tarea = tareasCtrl.tareas.firstWhereOrNull((t) => t.id == accion.tareaId);
        if (tarea != null) {
          final ok = await tareasCtrl.avanzarEstado(tarea);
          if (ok) {
            mensajes.add(MensajeChat(
              id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
              texto: 'Acción realizada: La tarea "${tarea.titulo}" pasó al estado "${tarea.esPendiente ? 'En progreso' : 'Completada'}".',
              esUsuario: false,
            ));
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Limpia la conversación actual
  void limpiarConversacion() {
    mensajes.clear();
    mensajeError.value = '';
  }
}
