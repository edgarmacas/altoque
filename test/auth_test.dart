import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:altoque/controllers/auth_controller.dart';
import 'package:altoque/models/token.dart';
import 'package:altoque/models/usuario.dart';
import 'package:altoque/screens/login_screen.dart';
import 'package:altoque/screens/registro_screen.dart';
import 'package:altoque/services/api_client.dart';

void main() {
  group('Paso 3 — Modelos y Autenticación', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      Get.reset();
      final client = ApiClient();
      Get.put<ApiClient>(client);
      Get.put<AuthController>(AuthController(apiClient: client));
    });

    test('Usuario model serializa y deserializa correctamente', () {
      final json = {
        'id': 1,
        'email': 'test@ejemplo.com',
        'creado_en': '2026-10-21T10:00:00.000Z',
      };
      final u = Usuario.fromJson(json);

      expect(u.id, 1);
      expect(u.email, 'test@ejemplo.com');
      expect(u.creadoEn, isNotNull);
      expect(u.toJson()['email'], 'test@ejemplo.com');
    });

    test('Token model serializa y deserializa correctamente', () {
      final json = {
        'access_token': 'jwt_token_123',
        'token_type': 'bearer',
      };
      final t = Token.fromJson(json);

      expect(t.accessToken, 'jwt_token_123');
      expect(t.tokenType, 'bearer');
      expect(t.toJson()['access_token'], 'jwt_token_123');
    });

    testWidgets('LoginScreen muestra campos de correo, clave y botón demo', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('AlToque'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Cargar usuario de prueba'), findsOneWidget);

      // Probar que el botón demo rellena los campos
      await tester.tap(find.text('Cargar usuario de prueba'));
      await tester.pump();

      expect(find.text('edgar@ejemplo.com'), findsOneWidget);
      expect(find.text('clave1234'), findsOneWidget);
    });

    testWidgets('RegistroScreen valida campos requeridos', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: RegistroScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Nueva cuenta'), findsOneWidget);
      final botonRegistrar = find.text('Registrarme');
      await tester.ensureVisible(botonRegistrar);
      expect(botonRegistrar, findsOneWidget);

      // Pulsar sin completar nada dispara validación
      await tester.tap(botonRegistrar);
      await tester.pump();

      expect(find.text('Ingresa tu correo'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    });
  });
}
