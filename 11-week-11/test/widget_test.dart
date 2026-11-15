import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_11/modul_11/modul_11_app.dart';

void main() {
  testWidgets('Aplikasi Modul 11 dapat ditampilkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul11App());

    expect(find.text('Menampilkan 1000 dari 1000 tugas'), findsOneWidget);
  });
}
