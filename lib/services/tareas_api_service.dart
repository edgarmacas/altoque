import 'package:dio/dio.dart';

import '../models/tarea.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Servicio de red para el CRUD de tareas contra el backend FastAPI.
class TareasApiService {
  final ApiClient _client;

  TareasApiService(this._client);

  /// Obtiene la lista de tareas del usuario autenticado.
  Future<List<Tarea>> listarTareas({
    int skip = 0,
    int limit = 100,
    String? estado,
    String? prioridad,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (estado != null && estado.isNotEmpty && estado != 'todos') {
        queryParams['estado'] = estado;
      }
      if (prioridad != null && prioridad.isNotEmpty && prioridad != 'todas') {
        queryParams['prioridad'] = prioridad;
      }

      final response = await _client.dio.get(
        '/tareas/',
        queryParameters: queryParams,
      );

      final lista = (response.data as List)
          .map((item) => Tarea.fromJson(item as Map<String, dynamic>))
          .toList();

      return lista;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }

  /// Crea una nueva tarea asociada al usuario autenticado.
  Future<Tarea> crearTarea({
    required String titulo,
    required String prioridad,
    String? descripcion,
    DateTime? fechaLimite,
  }) async {
    try {
      final payload = <String, dynamic>{
        'titulo': titulo.trim(),
        'prioridad': prioridad.toLowerCase(),
      };
      if (descripcion != null && descripcion.trim().isNotEmpty) {
        payload['descripcion'] = descripcion.trim();
      }
      if (fechaLimite != null) {
        payload['fecha_limite'] = fechaLimite.toIso8601String();
      }

      final response = await _client.dio.post(
        '/tareas/',
        data: payload,
      );

      return Tarea.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }

  /// Actualiza el estado de una tarea aplicando las reglas de transición y WIP.
  Future<Tarea> actualizarEstado(int id, String nuevoEstado) async {
    try {
      final response = await _client.dio.patch(
        '/tareas/$id/estado',
        data: {'estado': nuevoEstado},
      );

      return Tarea.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }

  /// Elimina permanentemente una tarea.
  Future<void> eliminarTarea(int id) async {
    try {
      await _client.dio.delete('/tareas/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }
}
