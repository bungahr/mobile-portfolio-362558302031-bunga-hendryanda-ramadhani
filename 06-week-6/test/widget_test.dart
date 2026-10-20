import 'package:flutter_test/flutter_test.dart';
import 'package:modul_06_tugas_praktikum/modul_06/modul_06_app.dart';

void main() {
  testWidgets('Aplikasi Modul 06 dapat ditampilkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul06App());

    expect(find.text('Login'), findsOneWidget);
  });
}
