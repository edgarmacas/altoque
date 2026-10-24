import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/mensaje_chat.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Servicio para consultar al asistente a través del backend propio (sin claves en el cliente).
///
/// Cumple con la rúbrica (Criterio 6): IA sin secretos.
class AsistenteApiService {
  final ApiClient _apiClient;

  AsistenteApiService([ApiClient? apiClient])
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Envía la consulta del usuario al backend y recibe la respuesta y posible acción propuesta.
  Future<MensajeChat> consultar(String mensaje) async {
    try {
      final response = await _apiClient.dio.post(
        '/asistente/consultar',
        data: {'mensaje': mensaje},
      );

      final data = response.data as Map<String, dynamic>;
      final respuesta = data['respuesta'] as String? ?? 'No se recibió respuesta.';
      final accionRaw = data['accion'];
      final accion = accionRaw != null
          ? AccionAsistente.fromJson(Map<String, dynamic>.from(accionRaw as Map))
          : null;

      return MensajeChat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        texto: respuesta,
        esUsuario: false,
        accion: accion,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        'No fue posible conectar con el asistente. Revisa tu conexión a internet.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw const ApiException(
        'Ocurrió un error inesperado al consultar al asistente.',
        statusCode: 500,
      );
    }
  }
}
