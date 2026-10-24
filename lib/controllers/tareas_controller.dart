import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/tarea.dart';
import '../repositories/tareas_repository.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/tareas_api_service.dart';
import '../utils/estado_carga.dart';

/// Controlador centralizado para la gestión del CRUD de tareas y persistencia en Hive.
///
/// Implementa el patrón del curso: «Hive guarda, Rx notifica».
class TareasController extends GetxController {
  final TareasRepository _repository;
  final Box<Map>? _destacadasBox;

  final RxList<Tarea> tareas = <Tarea>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;

  /// Espejo reactivo de tareas destacadas respaldado por Hive (Sesión 7)
  final RxList<Tarea> destacadas = <Tarea>[].obs;

  /// Filtros reactivos
  final RxString filtroEstado = 'todos'.obs;
  final RxString filtroPrioridad = 'todas'.obs;

  bool get estaCargando => estado.value == EstadoCarga.cargando;
  bool get desdeCache => _repository.desdeCache.value;
  int get totalTareas => tareas.length;
  int get totalPendientes => tareas.where((t) => t.esPendiente).length;
  int get totalEnProgreso => tareas.where((t) => t.esEnProgreso).length;
  int get totalCompletadas => tareas.where((t) => t.esCompletada).length;
  int get totalDestacadas => destacadas.length;

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

  /// Lista de tareas destacadas que sobreviven al reinicio de la app (Hive)
  List<Tarea> get tareasDestacadas => destacadas;

  TareasController({
    TareasRepository? repository,
    Box<Map>? destacadasBox,
  })  : _repository = repository ??
            TareasRepository(TareasApiService(Get.find<ApiClient>())),
        _destacadasBox = destacadasBox ??
            (Hive.isBoxOpen('tareas_destacadas')
                ? Hive.box<Map>('tareas_destacadas')
                : null);

  @override
  void onInit() {
    super.onInit();
    _cargarDestacadasDesdeHive();
    cargarTareas();
  }

  void _cargarDestacadasDesdeHive() {
    if (_destacadasBox != null) {
      destacadas.value = _destacadasBox.values
          .map((map) => Tarea.fromJson(Map<String, dynamic>.from(map)))
          .toList();
    }
  }

  bool esDestacada(int id) => destacadas.any((t) => t.id == id);

  /// Alterna el estado de destacada de una tarea y lo persiste en Hive.
  Future<void> toggleDestacada(Tarea tarea) async {
    if (esDestacada(tarea.id)) {
      if (_destacadasBox != null) {
        await _destacadasBox.delete(tarea.id);
      }
      destacadas.removeWhere((t) => t.id == tarea.id);
    } else {
      if (_destacadasBox != null) {
        await _destacadasBox.put(tarea.id, tarea.toJson());
      }
      destacadas.add(tarea);
    }
  }

  /// Carga o refresca la lista completa de tareas desde el servidor o caché de Hive.
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
      mensajeError.value = e.mensaje;
      return false;
    } catch (_) {
      mensajeError.value = 'Ocurrió un error inesperado al guardar la tarea.';
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
      return false;
    }

    try {
      final actualizada =
          await _repository.actualizarEstado(tarea.id, siguienteEstado);
      final index = tareas.indexWhere((t) => t.id == tarea.id);
      if (index != -1) {
        tareas[index] = actualizada;
      }
      // Si la tarea estaba en destacadas, actualizamos también su copia en Hive
      if (esDestacada(tarea.id)) {
        if (_destacadasBox != null) {
          await _destacadasBox.put(actualizada.id, actualizada.toJson());
        }
        final destIndex = destacadas.indexWhere((t) => t.id == tarea.id);
        if (destIndex != -1) {
          destacadas[destIndex] = actualizada;
        }
      }
      return true;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      return false;
    } catch (_) {
      mensajeError.value = 'No se pudo actualizar el estado de la tarea.';
      return false;
    }
  }

  /// Elimina una tarea por su identificador.
  Future<bool> eliminarTarea(int id) async {
    try {
      await _repository.eliminarTarea(id);
      tareas.removeWhere((t) => t.id == id);
      if (esDestacada(id)) {
        if (_destacadasBox != null) {
          await _destacadasBox.delete(id);
        }
        destacadas.removeWhere((t) => t.id == id);
      }
      return true;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      return false;
    } catch (_) {
      mensajeError.value = 'No se pudo eliminar la tarea.';
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
    destacadas.clear();
    filtroEstado.value = 'todos';
    filtroPrioridad.value = 'todas';
    mensajeError.value = '';
    estado.value = EstadoCarga.exito;
  }
}
