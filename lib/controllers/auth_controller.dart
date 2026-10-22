import 'package:get/get.dart';

import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../utils/estado_carga.dart';

/// Controlador centralizado para la autenticación y sesión del usuario con GetX.
class AuthController extends GetxController {
  final ApiClient _apiClient;
  late final AuthApiService _authService;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  final RxString emailActual = ''.obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;

  bool get estaAutenticado => emailActual.value.isNotEmpty;
  bool get estaCargando => estado.value == EstadoCarga.cargando;

  AuthController({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>() {
    _authService = AuthApiService(_apiClient);
  }

  @override
  void onInit() {
    super.onInit();
    restaurarSesion();
  }

  /// Restaura la sesión del usuario si existe un token previamente guardado.
  Future<void> restaurarSesion() async {
    try {
      final token = await _apiClient.leerToken();
      final email = await _apiClient.leerUsuarioEmail();

      if (token != null && token.isNotEmpty && email != null) {
        emailActual.value = email;
        usuario.value = Usuario(id: 0, email: email);
      }
    } catch (_) {
      try {
        await _apiClient.eliminarToken();
      } catch (_) {}
      emailActual.value = '';
      usuario.value = null;
    }
  }

  /// Inicia sesión con correo y contraseña. Retorna true si tuvo éxito.
  Future<bool> login(String email, String password) async {
    estado.value = EstadoCarga.cargando;
    mensajeError.value = '';

    try {
      await _authService.login(email, password);
      emailActual.value = email.trim();
      usuario.value = Usuario(id: 0, email: email.trim());
      estado.value = EstadoCarga.exito;
      return true;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
      return false;
    } catch (e) {
      mensajeError.value = 'No se pudo iniciar sesión. Verifica tu conexión.';
      estado.value = EstadoCarga.error;
      return false;
    }
  }

  /// Registra una nueva cuenta e inicia sesión automáticamente.
  Future<bool> registrarse(String email, String password) async {
    estado.value = EstadoCarga.cargando;
    mensajeError.value = '';

    try {
      await _authService.registrar(email, password);
      // Tras registrar con éxito, iniciamos sesión para obtener el token
      return await login(email, password);
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
      return false;
    } catch (e) {
      mensajeError.value = 'No se pudo completar el registro. Intenta más tarde.';
      estado.value = EstadoCarga.error;
      return false;
    }
  }

  /// Cierra la sesión activa y limpia credenciales almacenadas.
  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
    usuario.value = null;
    emailActual.value = '';
    mensajeError.value = '';
    estado.value = EstadoCarga.exito;
  }
}
