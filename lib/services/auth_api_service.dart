import 'package:dio/dio.dart';

import '../models/token.dart';
import '../models/usuario.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Servicio de red para operaciones de autenticación contra el backend FastAPI.
class AuthApiService {
  final ApiClient _client;

  AuthApiService(this._client);

  /// Inicia sesión enviando credenciales compatibles con OAuth2PasswordRequestForm (`/usuarios/token`).
  Future<Token> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/token',
        data: {
          'username': email.trim(),
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final token = Token.fromJson(response.data as Map<String, dynamic>);
      await _client.guardarToken(token.accessToken);
      await _client.guardarUsuarioEmail(email.trim());
      return token;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }

  /// Registra una nueva cuenta de usuario en el sistema (`/usuarios/`).
  Future<Usuario> registrar(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException.desdeDio(e);
    }
  }

  /// Cierra la sesión local borrando el token del almacenamiento seguro.
  Future<void> cerrarSesion() async {
    await _client.eliminarToken();
  }
}
