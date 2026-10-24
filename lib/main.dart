import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/auth_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'utils/reporte_errores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ReporteErrores.instalar();

  // Inicialización de persistencia local con Hive
  await Hive.initFlutter();
  await Hive.openBox<Map>('tareas_destacadas');
  await Hive.openBox<Map>('tareas_cache');

  inicializarDependencias();
  runApp(const AlToqueApp());
}

/// Registra los servicios y controladores globales si no han sido registrados.
void inicializarDependencias({String? baseUrl}) {
  if (!Get.isRegistered<ApiClient>()) {
    // Conexión al backend en puerto 8000
    final url = baseUrl ?? (kIsWeb ? 'http://127.0.0.1:8000' : null);
    Get.put<ApiClient>(ApiClient(baseUrl: url));
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DCED8),
          primary: const Color(0xFF0E8E98), // Turquesa profundo vibrante
          secondary: const Color(0xFFFF467A), // Coral enérgico
          tertiary: const Color(0xFF1DCED8), // Cyan puro
          surface: const Color(0xFFF8FAFC),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF467A),
          foregroundColor: Colors.white,
          elevation: 3,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF1DCED8).withValues(alpha: 0.22),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0E8E98),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: Obx(() {
        if (!auth.estaAutenticado) {
          return const LoginScreen();
        }
        return const HomeScreen();
      }),
    );
  }
}
