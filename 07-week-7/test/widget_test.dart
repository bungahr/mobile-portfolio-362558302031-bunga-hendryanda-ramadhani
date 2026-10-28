import 'package:flutter_test/flutter_test.dart';
import 'package:modul_07/modul_07/modul_07_app.dart';

void main() {
  testWidgets('Modul 07 menampilkan daftar tugas', (WidgetTester tester) async {
    await tester.pumpWidget(const Modul07App());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Tugas'), findsOneWidget);
  });
}
