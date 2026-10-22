import 'package:flutter_test/flutter_test.dart';
import 'package:altoque/main.dart';

void main() {
  testWidgets('AlToqueApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlToqueApp());

    expect(find.text('AlToque 🇪🇨'), findsOneWidget);
    expect(find.textContaining('¡Bienvenido a AlToque!'), findsOneWidget);
  });
}
