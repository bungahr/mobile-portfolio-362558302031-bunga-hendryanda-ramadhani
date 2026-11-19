import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_10/main_ai.dart';

void main() {
  testWidgets('layar mulai dengan simulator dan dapat beralih tanpa request', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DemoModelNyata()));
    expect(find.text('Simulator / jawaban tetap'), findsOneWidget);
    expect(find.textContaining('Tidak ada inferensi model'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ollama lokal / inferensi model nyata').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Riwayat tidak dikirim ulang'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
