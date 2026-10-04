import 'package:flutter_test/flutter_test.dart';

import 'package:week03/modul_03/modul_03_app.dart';

void main() {
  testWidgets('Fase A menampilkan daftar KRS', (WidgetTester tester) async {
    await tester.pumpWidget(const Modul03App());

    expect(find.text('Rencana Studi (KRS) TRPL'), findsOneWidget);

    expect(find.text('Pemrograman Perangkat Bergerak'), findsOneWidget);

    expect(find.text('15 / 24 SKS'), findsOneWidget);
  });

  testWidgets('Fase A membuka detail', (WidgetTester tester) async {
    await tester.pumpWidget(const Modul03App());

    await tester.tap(find.text('Pemrograman Perangkat Bergerak'));

    await tester.pumpAndSettle();

    expect(find.text('TRPL501'), findsOneWidget);
    expect(find.text('3 SKS'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
  });

  testWidgets('Fase A membuka form dan validasi', (WidgetTester tester) async {
    await tester.pumpWidget(const Modul03App());

    await tester.tap(find.text('Tambah MK'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Mata Kuliah KRS'), findsOneWidget);

    await tester.tap(find.text('Simpan ke Rencana Studi'));

    await tester.pumpAndSettle();

    expect(find.text('Kode mata kuliah wajib diisi'), findsOneWidget);

    expect(find.text('Nama mata kuliah wajib diisi'), findsOneWidget);
  });
}
