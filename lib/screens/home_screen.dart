import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'asistente_screen.dart';
import 'destacadas_screen.dart';
import 'perfil_screen.dart';
import 'tareas_screen.dart';

/// Pantalla contenedora principal con barra de navegación inferior de 4 pestañas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.put<HomeController>(HomeController());

    const pantallas = [
      TareasScreen(),
      DestacadasScreen(),
      AsistenteScreen(),
      PerfilScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: homeCtrl.tabActual.value,
            children: pantallas,
          )),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: homeCtrl.tabActual.value,
            onDestinationSelected: homeCtrl.cambiarTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt_rounded),
                label: 'Tareas',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_outline_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Destacadas',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy_rounded),
                label: 'Asistente',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          )),
    );
  }
}
