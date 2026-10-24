import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:altoque/controllers/auth_controller.dart';
import 'package:altoque/controllers/home_controller.dart';
import 'package:altoque/controllers/tareas_controller.dart';
import 'package:altoque/models/tarea.dart';
import 'package:altoque/models/usuario.dart';
import 'package:altoque/repositories/tareas_repository.dart';
import 'package:altoque/screens/destacadas_screen.dart';
import 'package:altoque/screens/home_screen.dart';
import 'package:altoque/screens/tareas_screen.dart';
import 'package:altoque/services/api_client.dart';
import 'package:altoque/widgets/tarea_card.dart';

class MockTareasRepository implements TareasRepository {
  List<Tarea> listaPrueba;
  @override
  final RxBool desdeCache = false.obs;

  MockTareasRepository(this.listaPrueba);

  @override
  Future<List<Tarea>> obtenerTareas({String? estado, String? prioridad}) async {
    return List<Tarea>.from(listaPrueba);
  }

  @override
  Future<Tarea> crearTarea({
    required String titulo,
    required String prioridad,
    String? descripcion,
    DateTime? fechaLimite,
  }) async {
    final nueva = Tarea(
      id: listaPrueba.length + 1,
      usuarioId: 1,
      titulo: titulo,
      prioridad: prioridad,
      descripcion: descripcion,
      fechaLimite: fechaLimite,
      estado: 'pendiente',
    );
    listaPrueba.insert(0, nueva);
    return nueva;
  }

  @override
  Future<Tarea> actualizarEstado(int id, String nuevoEstado) async {
    final index = listaPrueba.indexWhere((t) => t.id == id);
    final actualizada = listaPrueba[index].copyWith(estado: nuevoEstado);
    listaPrueba[index] = actualizada;
    return actualizada;
  }

  @override
  Future<void> eliminarTarea(int id) async {
    listaPrueba.removeWhere((t) => t.id == id);
  }
}

void main() {
  group('Paso 4 — CRUD y Pantalla de Tareas', () {
    final tareaDemo = Tarea(
      id: 1,
      usuarioId: 1,
      titulo: 'Renovar cédula en Registro Civil',
      descripcion: 'Turno en agencia Quitumbe',
      prioridad: 'alta',
      estado: 'pendiente',
    );

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      Get.reset();
      final client = ApiClient();
      Get.put<ApiClient>(client);
      final auth = Get.put<AuthController>(AuthController(apiClient: client));
      auth.emailActual.value = 'edgar@ejemplo.com';
      auth.usuario.value = const Usuario(id: 1, email: 'edgar@ejemplo.com');
    });

    test('Tarea model serializa y calcula estados correctamente', () {
      final json = tareaDemo.toJson();
      final reconstruida = Tarea.fromJson(json);

      expect(reconstruida.titulo, 'Renovar cédula en Registro Civil');
      expect(reconstruida.esPrioridadAlta, isTrue);
      expect(reconstruida.esPendiente, isTrue);
      expect(reconstruida.etiquetaPrioridad, 'Alta');
      expect(reconstruida.etiquetaEstado, 'Pendiente');
    });

    test('TareasController calcula contadores y filtros reactivamente', () async {
      final repo = MockTareasRepository([
        tareaDemo,
        const Tarea(
          id: 2,
          usuarioId: 1,
          titulo: 'Comprar víveres',
          prioridad: 'baja',
          estado: 'en_progreso',
        ),
        const Tarea(
          id: 3,
          usuarioId: 1,
          titulo: 'Pagar matrícula vehicular',
          prioridad: 'media',
          estado: 'completada',
        ),
      ]);

      final controller = TareasController(repository: repo);
      await controller.cargarTareas();

      expect(controller.totalTareas, 3);
      expect(controller.totalPendientes, 1);
      expect(controller.totalEnProgreso, 1);
      expect(controller.totalCompletadas, 1);

      // Probar filtro por estado
      controller.cambiarFiltroEstado('en_progreso');
      expect(controller.tareasFiltradas.length, 1);
      expect(controller.tareasFiltradas.first.titulo, 'Comprar víveres');

      controller.cambiarFiltroEstado('todos');
      expect(controller.tareasFiltradas.length, 3);
    });

    testWidgets('TareaCard muestra título, badges y dispara avance de estado', (tester) async {
      var avanzadado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TareaCard(
              tarea: tareaDemo,
              onAvanzarEstado: () => avanzadado = true,
              onEliminar: () {},
            ),
          ),
        ),
      );

      expect(find.text('Renovar cédula en Registro Civil'), findsOneWidget);
      expect(find.text('Turno en agencia Quitumbe'), findsOneWidget);
      expect(find.text('Prioridad: Alta'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);

      // Tocar botón de avanzar estado
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(avanzadado, isTrue);
    });

    testWidgets('TareasScreen muestra chips de filtro y botón flotante', (tester) async {
      final repo = MockTareasRepository([tareaDemo]);
      Get.put<TareasController>(TareasController(repository: repo));

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TareasScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('AlToque'), findsOneWidget);
      expect(find.text('Nueva tarea'), findsOneWidget);
      expect(find.textContaining('Todas'), findsOneWidget);
      expect(find.textContaining('Pendientes'), findsOneWidget);
      expect(find.text('Renovar cédula en Registro Civil'), findsOneWidget);
    });
    testWidgets('DestacadasScreen muestra tareas destacadas', (tester) async {
      final repo = MockTareasRepository([tareaDemo]);
      final controller = Get.put<TareasController>(TareasController(repository: repo));
      controller.destacadas.assignAll([tareaDemo]);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: DestacadasScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Tareas destacadas'), findsOneWidget);
      expect(find.text('1 tareas guardadas localmente'), findsOneWidget);
      expect(find.text('Renovar cédula en Registro Civil'), findsOneWidget);
    });

    testWidgets('HomeScreen muestra las 4 pestañas de navegación', (tester) async {
      final repo = MockTareasRepository([tareaDemo]);
      Get.put<TareasController>(TareasController(repository: repo));
      Get.put<HomeController>(HomeController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Tareas'), findsOneWidget);
      expect(find.text('Destacadas'), findsOneWidget);
      expect(find.text('Asistente'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });
  });
}
