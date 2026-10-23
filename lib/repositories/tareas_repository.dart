import '../models/tarea.dart';
import '../services/tareas_api_service.dart';

/// Repositorio de tareas que abstrae el origen de datos para los controladores.
///
/// Siguiendo la arquitectura en capas:
/// Pantalla -> Controlador (GetX) -> Repositorio -> Servicio de API / Almacenamiento local.
class TareasRepository {
  final TareasApiService _api;

  TareasRepository(this._api);

  Future<List<Tarea>> obtenerTareas({String? estado, String? prioridad}) {
    return _api.listarTareas(estado: estado, prioridad: prioridad);
  }

  Future<Tarea> crearTarea({
    required String titulo,
    required String prioridad,
    String? descripcion,
    DateTime? fechaLimite,
  }) {
    return _api.crearTarea(
      titulo: titulo,
      prioridad: prioridad,
      descripcion: descripcion,
      fechaLimite: fechaLimite,
    );
  }

  Future<Tarea> actualizarEstado(int id, String nuevoEstado) {
    return _api.actualizarEstado(id, nuevoEstado);
  }

  Future<void> eliminarTarea(int id) {
    return _api.eliminarTarea(id);
  }
}
