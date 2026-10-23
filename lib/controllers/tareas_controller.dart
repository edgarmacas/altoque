import 'package:get/get.dart';

import '../models/tarea.dart';
import '../repositories/tareas_repository.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/tareas_api_service.dart';
import '../utils/estado_carga.dart';

/// Controlador centralizado para la gestión del CRUD de tareas con GetX.
class TareasController extends GetxController {
  final TareasRepository _repository;

  final RxList<Tarea> tareas = <Tarea>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;

  /// Filtros reactivos
  final RxString filtroEstado = 'todos'.obs;
  final RxString filtroPrioridad = 'todas'.obs;

  bool get estaCargando => estado.value == EstadoCarga.cargando;
  int get totalTareas => tareas.length;
  int get totalPendientes => tareas.where((t) => t.esPendiente).length;
  int get totalEnProgreso => tareas.where((t) => t.esEnProgreso).length;
  int get totalCompletadas => tareas.where((t) => t.esCompletada).length;

  /// Lista reactiva calculada según los filtros activos
  List<Tarea> get tareasFiltradas {
    return tareas.where((t) {
      final coincideEstado =
          filtroEstado.value == 'todos' || t.estado == filtroEstado.value;
      final coincidePrioridad =
          filtroPrioridad.value == 'todas' || t.prioridad == filtroPrioridad.value;
      return coincideEstado && coincidePrioridad;
    }).toList();
  }

  TareasController({TareasRepository? repository})
      : _repository = repository ??
            TareasRepository(TareasApiService(Get.find<ApiClient>()));

  @override
  void onInit() {
    super.onInit();
    cargarTareas();
  }

  /// Carga o refresca la lista completa de tareas desde el servidor.
  Future<void> cargarTareas() async {
    estado.value = EstadoCarga.cargando;
    mensajeError.value = '';

    try {
      final lista = await _repository.obtenerTareas();
      tareas.assignAll(lista);
      estado.value = EstadoCarga.exito;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
    } catch (_) {
      mensajeError.value =
          'No se pudo conectar con el servidor. Verifica que el backend esté activo.';
      estado.value = EstadoCarga.error;
    }
  }

  /// Crea una nueva tarea y refresca el listado.
  Future<bool> crearTarea({
    required String titulo,
    required String prioridad,
    String? descripcion,
    DateTime? fechaLimite,
  }) async {
    try {
      final nueva = await _repository.crearTarea(
        titulo: titulo,
        prioridad: prioridad,
        descripcion: descripcion,
        fechaLimite: fechaLimite,
      );
      tareas.insert(0, nueva);
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'No se pudo crear la tarea',
        e.mensaje,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado al guardar la tarea.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Avanza el estado de una tarea aplicando las reglas de transición del backend:
  /// pendiente -> en_progreso -> completada.
  Future<bool> avanzarEstado(Tarea tarea) async {
    String siguienteEstado;
    if (tarea.esPendiente) {
      siguienteEstado = 'en_progreso';
    } else if (tarea.esEnProgreso) {
      siguienteEstado = 'completada';
    } else {
      return false; // Ya completada
    }

    try {
      final actualizada =
          await _repository.actualizarEstado(tarea.id, siguienteEstado);
      final index = tareas.indexWhere((t) => t.id == tarea.id);
      if (index != -1) {
        tareas[index] = actualizada;
      }
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Transición no permitida',
        e.mensaje,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el estado de la tarea.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Elimina una tarea por su identificador.
  Future<bool> eliminarTarea(int id) async {
    try {
      await _repository.eliminarTarea(id);
      tareas.removeWhere((t) => t.id == id);
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'No se pudo eliminar',
        e.mensaje,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la tarea.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void cambiarFiltroEstado(String nuevoFiltro) {
    filtroEstado.value = nuevoFiltro;
  }

  void cambiarFiltroPrioridad(String nuevaPrioridad) {
    filtroPrioridad.value = nuevaPrioridad;
  }

  void limpiar() {
    tareas.clear();
    filtroEstado.value = 'todos';
    filtroPrioridad.value = 'todas';
    mensajeError.value = '';
    estado.value = EstadoCarga.exito;
  }
}
