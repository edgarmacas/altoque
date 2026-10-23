import 'package:get/get.dart';

/// Controlador para la navegación por pestañas de la pantalla principal.
class HomeController extends GetxController {
  final RxInt tabActual = 0.obs;

  void cambiarTab(int indice) {
    tabActual.value = indice;
  }
}
