import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_exception.dart';

/// Cliente HTTP centralizado con Dio.
///
/// Implementa interceptores para:
/// 1. Adjuntar automáticamente `Authorization: Bearer <token>` cuando existe sesión.
/// 2. Adaptar la URL base según la plataforma (Web/Linux vs Emulador Android).
/// 3. Transformar errores de red en excepciones legibles de tipo `ApiException`.
class ApiClient {
  static const String claveToken = 'altoque_jwt_token';
  static const String claveUsuario = 'altoque_usuario_email';

  final FlutterSecureStorage _storage;
  late final Dio dio;

  /// URL por defecto según la plataforma
  static String get urlPorDefecto {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
    Dio? dioInstancia,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    final url = baseUrl ?? urlPorDefecto;
    dio = dioInstancia ??
        Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Accept': 'application/json'},
          ),
        );

    _configurarInterceptores();
  }

  void _configurarInterceptores() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Si la petición ya incluye cabecera Authorization explícita, se respeta
          if (!options.headers.containsKey('Authorization')) {
            final token = await leerToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Convierte DioException en nuestra ApiException para consumo en capas superiores
          final apiEx = ApiException.desdeDio(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: apiEx,
            ),
          );
        },
      ),
    );
  }

  Future<String?> leerToken() async {
    try {
      return await _storage.read(key: claveToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarToken(String token) async {
    await _storage.write(key: claveToken, value: token);
  }

  Future<void> eliminarToken() async {
    await _storage.delete(key: claveToken);
    await _storage.delete(key: claveUsuario);
  }

  Future<void> guardarUsuarioEmail(String email) async {
    await _storage.write(key: claveUsuario, value: email);
  }

  Future<String?> leerUsuarioEmail() async {
    try {
      return await _storage.read(key: claveUsuario);
    } catch (_) {
      return null;
    }
  }
}
