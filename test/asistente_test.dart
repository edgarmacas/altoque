import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:altoque/controllers/asistente_controller.dart';
import 'package:altoque/controllers/auth_controller.dart';
import 'package:altoque/controllers/tareas_controller.dart';
import 'package:altoque/models/mensaje_chat.dart';
import 'package:altoque/models/tarea.dart';
import 'package:altoque/models/usuario.dart';
import 'package:altoque/repositories/tareas_repository.dart';
import 'package:altoque/screens/asistente_screen.dart';
import 'package:altoque/services/api_client.dart';
import 'package:altoque/services/api_exception.dart';
import 'package:altoque/services/asistente_api_service.dart';

class FakeSuccessAsistenteApiService implements AsistenteApiService {
  final MensajeChat respuestaPersonalizada;

  FakeSuccessAsistenteApiService([MensajeChat? respuesta])
      : respuestaPersonalizada = respuesta ??
            MensajeChat(
              id: 'test_resp_1',
              texto: 'Te recomiendo comenzar por tu tarea de prioridad alta.',
              esUsuario: false,
              accion: const AccionAsistente(
                tipo: 'iniciar_tarea',
                tareaId: 42,
                titulo: 'Entregar informe mensual',
              ),
            );

  @override
  Future<MensajeChat> consultar(String mensaje) async {
    return respuestaPersonalizada;
  }
}

class FakeErrorAsistenteApiService implements AsistenteApiService {
  @override
  Future<MensajeChat> consultar(String mensaje) async {
    throw const ApiException(
      'Fallo simulado de conexión con el backend',
      statusCode: 500,
    );
  }
}

class FakeTareasRepoParaAsistente implements TareasRepository {
  List<Tarea> lista;
  @override
  final RxBool desdeCache = false.obs;

  FakeTareasRepoParaAsistente(this.lista);

  @override
  Future<List<Tarea>> obtenerTareas({String? estado, String? prioridad}) async => List.from(lista);

  @override
  Future<Tarea> actualizarEstado(int id, String nuevoEstado) async {
    final idx = lista.indexWhere((t) => t.id == id);
    final actualizada = lista[idx].copyWith(estado: nuevoEstado);
    lista[idx] = actualizada;
    return actualizada;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Paso 6 — Asistente de IA (Servidor sin secretos)', () {
    setUp(() {
      Get.reset();
      FlutterSecureStorage.setMockInitialValues({});
      final client = ApiClient();
      Get.put<ApiClient>(client);
      final auth = Get.put<AuthController>(AuthController(apiClient: client));
      auth.emailActual.value = 'edgar@ejemplo.com';
      auth.usuario.value = const Usuario(id: 1, email: 'edgar@ejemplo.com');
    });

    test('MensajeChat y AccionAsistente serializan y deserializan correctamente', () {
      final json = {
        'id': 'm1',
        'texto': 'Prioriza la tarea alta',
        'es_usuario': false,
        'fecha': '2026-10-24T18:00:00.000Z',
        'accion': {
          'tipo': 'iniciar_tarea',
          'tarea_id': 10,
          'titulo': 'Renovar cédula',
        },
      };

      final msg = MensajeChat.fromJson(json);

      expect(msg.id, 'm1');
      expect(msg.texto, 'Prioriza la tarea alta');
      expect(msg.esUsuario, isFalse);
      expect(msg.accion, isNotNull);
      expect(msg.accion!.tipo, 'iniciar_tarea');
      expect(msg.accion!.tareaId, 10);
      expect(msg.accion!.titulo, 'Renovar cédula');

      final serializado = msg.toJson();
      expect(serializado['id'], 'm1');
      expect(serializado['accion']['tipo'], 'iniciar_tarea');
    });

    test('AsistenteController envía consulta y agrega respuesta a la conversación', () async {
      final fakeService = FakeSuccessAsistenteApiService();
      final controller = AsistenteController(apiService: fakeService);

      expect(controller.tieneMensajes, isFalse);

      await controller.enviarMensaje('¿Cuáles tareas debo priorizar hoy?');

      expect(controller.mensajes.length, 2);
      expect(controller.mensajes[0].esUsuario, isTrue);
      expect(controller.mensajes[0].texto, '¿Cuáles tareas debo priorizar hoy?');

      expect(controller.mensajes[1].esUsuario, isFalse);
      expect(controller.mensajes[1].texto, contains('prioridad alta'));
      expect(controller.mensajes[1].accion, isNotNull);
      expect(controller.mensajes[1].accion!.tareaId, 42);
    });

    test('AsistenteController captura errores de red sin romper la interfaz', () async {
      final fakeErrorService = FakeErrorAsistenteApiService();
      final controller = AsistenteController(apiService: fakeErrorService);

      await controller.enviarMensaje('Hola asistente');

      expect(controller.mensajes.length, 2);
      expect(controller.mensajes[1].texto, contains('Fallo simulado de conexión'));
      expect(controller.mensajeError.value, 'Fallo simulado de conexión con el backend');
    });

    test('AsistenteController ejecuta la acción sugerida en TareasController', () async {
      const tareaPrueba = Tarea(
        id: 42,
        usuarioId: 1,
        titulo: 'Entregar informe mensual',
        prioridad: 'alta',
        estado: 'pendiente',
      );

      final tareasRepo = FakeTareasRepoParaAsistente([tareaPrueba]);
      final tareasCtrl = Get.put<TareasController>(TareasController(repository: tareasRepo));
      tareasCtrl.tareas.assignAll([tareaPrueba]);

      final controller = AsistenteController(apiService: FakeSuccessAsistenteApiService());

      final exito = await controller.ejecutarAccion(const AccionAsistente(
        tipo: 'iniciar_tarea',
        tareaId: 42,
        titulo: 'Entregar informe mensual',
      ));

      expect(exito, isTrue);
      expect(tareasCtrl.tareas.first.esEnProgreso, isTrue);
      expect(controller.mensajes.last.texto, contains('pasó al estado "En progreso"'));
    });

    testWidgets('AsistenteScreen muestra bienvenida, sugerencias iniciales y barra de entrada', (tester) async {
      Get.put<AsistenteController>(
        AsistenteController(apiService: FakeSuccessAsistenteApiService()),
      );

      await tester.pumpWidget(
        const GetMaterialApp(
          home: AsistenteScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Asistente AlToque'), findsOneWidget);
      expect(find.text('Asistente de Productividad'), findsOneWidget);
      expect(find.text('Conexión segura vía backend. No se comparten claves en el dispositivo.'), findsOneWidget);
      expect(find.text('¿Cuáles tareas debo priorizar hoy?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
