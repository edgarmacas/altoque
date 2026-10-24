import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/tarea.dart';
import '../services/tareas_api_service.dart';

/// Repositorio de tareas con soporte de caché local en Hive para modo offline.
///
/// Siguiendo la arquitectura en capas:
/// Pantalla -> Controlador (GetX) -> Repositorio -> Red (FastAPI) / Persistencia Local (Hive).
class TareasRepository {
  final TareasApiService _api;
  final Box<Map>? _cacheBox;

  /// Indica si la última consulta provino de la caché local por falta de conexión.
  final RxBool desdeCache = false.obs;

  TareasRepository(this._api, {Box<Map>? cacheBox})
      : _cacheBox = cacheBox ??
            (Hive.isBoxOpen('tareas_cache') ? Hive.box<Map>('tareas_cache') : null);

  /// Obtiene la lista de tareas; si el servidor falla, recupera la copia de Hive.
  Future<List<Tarea>> obtenerTareas({String? estado, String? prioridad}) async {
    try {
      final remotas = await _api.listarTareas(estado: estado, prioridad: prioridad);
      desdeCache.value = false;

      // Actualizar la caché local en Hive cuando el servidor responde con éxito
      if (_cacheBox != null) {
        await _cacheBox.clear();
        for (final t in remotas) {
          await _cacheBox.put(t.id, t.toJson());
        }
      }
      return remotas;
    } catch (e) {
      // Si el servidor no responde pero tenemos datos en caché, los devolvemos
      if (_cacheBox != null && _cacheBox.isNotEmpty) {
        desdeCache.value = true;
        final locales = _cacheBox.values
            .map((map) => Tarea.fromJson(Map<String, dynamic>.from(map)))
            .where((t) {
              final coincideEstado =
                  estado == null || estado.isEmpty || estado == 'todos' || t.estado == estado;
              final coincidePrioridad =
                  prioridad == null || prioridad.isEmpty || prioridad == 'todas' || t.prioridad == prioridad;
              return coincideEstado && coincidePrioridad;
            })
            .toList();
        return locales;
      }
      rethrow;
    }
  }

  Future<Tarea> crearTarea({
    required String titulo,
    required String prioridad,
    String? descripcion,
    DateTime? fechaLimite,
  }) async {
    final nueva = await _api.crearTarea(
      titulo: titulo,
      prioridad: prioridad,
      descripcion: descripcion,
      fechaLimite: fechaLimite,
    );
    // Guardar en caché local
    if (_cacheBox != null) {
      await _cacheBox.put(nueva.id, nueva.toJson());
    }
    return nueva;
  }

  Future<Tarea> actualizarEstado(int id, String nuevoEstado) async {
    final actualizada = await _api.actualizarEstado(id, nuevoEstado);
    // Reflejar en caché local
    if (_cacheBox != null) {
      await _cacheBox.put(actualizada.id, actualizada.toJson());
    }
    return actualizada;
  }

  Future<void> eliminarTarea(int id) async {
    await _api.eliminarTarea(id);
    // Eliminar de caché local
    if (_cacheBox != null) {
      await _cacheBox.delete(id);
    }
  }
}
