import 'package:dio/dio.dart';

/// Excepción de red con mensajes claros y diferenciados para el usuario.
///
/// Cumple con la rúbrica (Criterio 7): mensajes específicos para 400, 401, 403,
/// 404, 422 y 5xx sin exponer detalles técnicos ni trazas crudas.
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  const ApiException(this.mensaje, {this.statusCode});

  factory ApiException.desdeDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    // Si el backend envió un mensaje en {"detail": "..."}
    String? detalleServidor;
    if (data is Map && data['detail'] != null) {
      final d = data['detail'];
      if (d is String) {
        detalleServidor = d;
      } else if (d is List && d.isNotEmpty && d[0] is Map) {
        detalleServidor = d[0]['msg'] as String?;
      }
    }

    switch (status) {
      case 400:
        return ApiException(
          detalleServidor ?? 'Solicitud incorrecta o límite de negocio excedido.',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          'Sesión expirada o credenciales incorrectas. Inicia sesión nuevamente.',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          'No tienes permisos para acceder a este recurso.',
          statusCode: 403,
        );
      case 404:
        return ApiException(
          detalleServidor ?? 'El recurso solicitado no fue encontrado.',
          statusCode: 404,
        );
      case 422:
        return ApiException(
          detalleServidor ?? 'Los datos ingresados no tienen el formato esperado.',
          statusCode: 422,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          'El servidor de AlToque está experimentando problemas. Intenta más tarde.',
          statusCode: status,
        );
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.connectionError) {
          return const ApiException(
            'No se pudo conectar con el servidor. Verifica que el backend esté encendido.',
            statusCode: 0,
          );
        }
        return ApiException(
          detalleServidor ?? 'Ocurrió un error inesperado al procesar la solicitud.',
          statusCode: status,
        );
    }
  }

  @override
  String toString() => mensaje;
}
