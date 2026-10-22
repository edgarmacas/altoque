import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'utils/reporte_errores.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ReporteErrores.instalar();
  inicializarDependencias();
  runApp(const AlToqueApp());
}

/// Registra los servicios y controladores globales si no han sido registrados.
void inicializarDependencias() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.put<ApiClient>(ApiClient());
  }
  if (!Get.isRegistered<AuthController>()) {
    Get.put<AuthController>(AuthController(apiClient: Get.find<ApiClient>()));
  }
}

/// Aplicación principal AlToque.
class AlToqueApp extends StatelessWidget {
  const AlToqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    inicializarDependencias();
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'AlToque — Tareas Personales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Azul institucional
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: Obx(() {
        if (!auth.estaAutenticado) {
          return const LoginScreen();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('AlToque'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: auth.cerrarSesion,
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    '¡Sesión iniciada!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuario: ${auth.emailActual.value}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: auth.cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
