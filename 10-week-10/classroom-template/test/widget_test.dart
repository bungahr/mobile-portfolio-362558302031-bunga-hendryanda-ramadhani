import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_10/modul_10_app.dart';

void main() {
  testWidgets('Aplikasi Modul 10 dapat ditampilkan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul10App());

    expect(find.text('Obrolan AI'), findsOneWidget);
  });
}
