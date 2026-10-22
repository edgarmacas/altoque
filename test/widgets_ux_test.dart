import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:altoque/widgets/loading_view.dart';
import 'package:altoque/widgets/empty_view.dart';
import 'package:altoque/widgets/error_view.dart';
import 'package:altoque/widgets/error_pantalla_view.dart';
import 'package:altoque/utils/reporte_errores.dart';

void main() {
  group('Paso 2 — Vistas UX y Manejo de Errores', () {
    testWidgets('LoadingView muestra CircularProgressIndicator y mensaje', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingView(mensaje: 'Consultando tareas...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Consultando tareas...'), findsOneWidget);
    });

    testWidgets('EmptyView muestra ícono y mensaje de ausencia de datos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(mensaje: 'No tienes tareas pendientes'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No tienes tareas pendientes'), findsOneWidget);
    });

    testWidgets('ErrorView muestra mensaje y ejecuta callback de reintento al pulsar el botón', (tester) async {
      var reintentado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              mensaje: 'Servidor no disponible',
              onReintentar: () => reintentado = true,
            ),
          ),
        ),
      );

      expect(find.text('Servidor no disponible'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(reintentado, isTrue);
    });

    testWidgets('ErrorPantallaView renderiza vista amigable sin pantalla roja', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorPantallaView(),
        ),
      );

      expect(find.text('Algo no salió como esperábamos'), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_dissatisfied_outlined), findsOneWidget);
    });

    test('ReporteErrores.limpiar sanitiza Bearer tokens y JWTs en logs', () {
      const textoConToken = 'Error 401: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIn0.xyz y token eyJhbGciOi.eyJzdWIi.abc';
      final resultado = ReporteErrores.limpiar(textoConToken);

      expect(resultado, isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')));
      expect(resultado, contains('Bearer ***'));
      expect(resultado, contains('***'));
    });
  });
}
