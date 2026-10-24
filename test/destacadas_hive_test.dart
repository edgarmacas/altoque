import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:altoque/controllers/auth_controller.dart';
import 'package:altoque/controllers/tareas_controller.dart';
import 'package:altoque/models/tarea.dart';
import 'package:altoque/models/usuario.dart';
import 'package:altoque/repositories/tareas_repository.dart';
import 'package:altoque/services/api_client.dart';
import 'package:altoque/services/tareas_api_service.dart';

class FakeErrorTareasApiService implements TareasApiService {
  @override
  Future<List<Tarea>> listarTareas({int skip = 0, int limit = 100, String? estado, String? prioridad}) async {
    throw Exception('Error de conexión simulado para prueba offline');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSuccessTareasRepository implements TareasRepository {
  List<Tarea> lista;
  @override
  final RxBool desdeCache = false.obs;

  FakeSuccessTareasRepository(this.lista);

  @override
  Future<List<Tarea>> obtenerTareas({String? estado, String? prioridad}) async => List.from(lista);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tempDir;
  late Box<Map> destacadasBox;
  late Box<Map> cacheBox;

  const tareaPrueba = Tarea(
    id: 101,
    usuarioId: 1,
    titulo: 'Comprar víveres en el supermercado',
    descripcion: 'Frutas, verduras y café',
    prioridad: 'media',
    estado: 'pendiente',
  );

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_destacadas_test');
    Hive.init(tempDir.path);
    destacadasBox = await Hive.openBox<Map>('tareas_destacadas');
    cacheBox = await Hive.openBox<Map>('tareas_cache');
  });

  setUp(() async {
    Get.reset();
    FlutterSecureStorage.setMockInitialValues({});
    await destacadasBox.clear();
    await cacheBox.clear();

    final client = ApiClient();
    Get.put<ApiClient>(client);
    final auth = Get.put<AuthController>(AuthController(apiClient: client));
    auth.emailActual.value = 'edgar@ejemplo.com';
    auth.usuario.value = const Usuario(id: 1, email: 'edgar@ejemplo.com');
  });

  group('Paso 5 — Persistencia con Hive (Destacadas y Caché Offline)', () {
    test('toggleDestacada guarda y elimina en Hive correctamente', () async {
      final controller = TareasController(
        repository: FakeSuccessTareasRepository([tareaPrueba]),
        destacadasBox: destacadasBox,
      );
      controller.tareas.assignAll([tareaPrueba]);

      expect(controller.esDestacada(tareaPrueba.id), isFalse);
      expect(destacadasBox.containsKey(tareaPrueba.id), isFalse);

      // 1. Destacar
      await controller.toggleDestacada(tareaPrueba);

      expect(controller.esDestacada(tareaPrueba.id), isTrue);
      expect(destacadasBox.containsKey(tareaPrueba.id), isTrue);
      expect(controller.totalDestacadas, 1);
      expect(controller.tareasDestacadas.first.titulo, 'Comprar víveres en el supermercado');

      // 2. Desmarcar
      await controller.toggleDestacada(tareaPrueba);

      expect(controller.esDestacada(tareaPrueba.id), isFalse);
      expect(destacadasBox.containsKey(tareaPrueba.id), isFalse);
      expect(controller.totalDestacadas, 0);
    });

    test('TareasController restaura tareas destacadas desde Hive al inicializar', () async {
      await destacadasBox.put(tareaPrueba.id, tareaPrueba.toJson());

      final controller = TareasController(
        repository: FakeSuccessTareasRepository([tareaPrueba]),
        destacadasBox: destacadasBox,
      );
      controller.onInit();

      expect(controller.destacadas.length, 1);
      expect(controller.destacadas.first.titulo, 'Comprar víveres en el supermercado');
      expect(controller.esDestacada(tareaPrueba.id), isTrue);
    });

    test('TareasRepository rescata tareas de la caché de Hive si el servidor no responde', () async {
      // Precargar la caché de Hive
      await cacheBox.put(tareaPrueba.id, tareaPrueba.toJson());

      final repo = TareasRepository(
        FakeErrorTareasApiService(),
        cacheBox: cacheBox,
      );

      final tareas = await repo.obtenerTareas();

      expect(repo.desdeCache.value, isTrue);
      expect(tareas.length, 1);
      expect(tareas.first.id, 101);
      expect(tareas.first.titulo, 'Comprar víveres en el supermercado');
    });
  });
}
