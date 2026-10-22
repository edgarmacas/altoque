import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:altoque/main.dart';

void main() {
  testWidgets('AlToqueApp smoke test muestra pantalla de login inicialmente', (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    Get.reset();
    await tester.pumpWidget(const AlToqueApp());
    await tester.pump();

    expect(find.text('AlToque'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
