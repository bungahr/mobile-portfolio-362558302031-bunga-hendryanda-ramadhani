import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_11/modul_11/modul_11_app.dart';

void main() {
  testWidgets('Aplikasi Modul 11 dapat ditampilkan', (tester) async {
    await tester.pumpWidget(const Modul11App());

    expect(find.text('Daftar 1.000 Tugas'), findsOneWidget);
    expect(find.text('1000/1000'), findsOneWidget);
  });
}
