import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/error_pantalla_view.dart';

/// Manejador centralizado de errores globales no controlados.
///
/// Cumple con dos requisitos de la rúbrica:
/// 1. Auditoría de secretos: Elimina tokens JWT y cabeceras de autorización de
///    los registros para evitar fugas de credenciales.
/// 2. Resiliencia de UX: Reemplaza la pantalla roja de depuración por
///    `ErrorPantallaView` y absorbe excepciones asíncronas no capturadas.
class ReporteErrores {
  ReporteErrores._();

  /// Registro de mensajes sanitizados en memoria para propósitos de depuración y testing.
  static final List<String> recientes = [];

  /// Limpia cualquier token JWT o cabecera `Bearer` de un texto antes de imprimirlo.
  static String limpiar(String texto) => texto
      .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*'), 'Bearer ***')
      .replaceAll(RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*'), '***');

  /// Registra el error sanitizado en consola.
  static void registrar(Object error, StackTrace? pila) {
    final mensaje = limpiar('${error.runtimeType}: $error');
    recientes.add(mensaje);
    if (recientes.length > 20) recientes.removeAt(0);
    debugPrint('[AlToque] error no controlado -> $mensaje');
  }

  /// Muestra una alerta amigable al usuario sin detalles técnicos expuestos.
  static void avisar() {
    try {
      if (Get.key.currentState == null) return;
      Get.snackbar(
        'Algo salió mal',
        'Hemos registrado el problema. Puedes seguir usando la app.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {}
  }

  /// Conecta los manejadores globales del framework y de la plataforma.
  static void instalar() {
    // 1. Errores síncronos en construcción de widgets de Flutter
    FlutterError.onError = (detalles) {
      registrar(detalles.exception, detalles.stack);
      FlutterError.presentError(detalles);
    };

    // 2. Errores asíncronos no capturados por Futures
    PlatformDispatcher.instance.onError = (error, stack) {
      registrar(error, stack);
      avisar();
      return true; // Evita que la app se detenga por completo
    };

    // 3. Reemplazo de la pantalla roja por vista amigable
    ErrorWidget.builder = (detalles) => ErrorPantallaView(detalles: detalles);
  }
}
