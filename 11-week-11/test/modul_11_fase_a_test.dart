import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_11/modul_11/modul_11_app.dart';

void main() {
  group('data contoh', () {
    test('membuat 1.000 tugas dengan 250 tugas selesai', () {
      final tugas = buatTugasContoh();
      expect(tugas, hasLength(1000));
      expect(tugas.where((t) => t.selesai), hasLength(250));
      expect(tugas.first.judul, 'Tugas praktikum 0001');
    });

    test('kunci pencarian dihitung sekali dalam huruf kecil', () {
      final t = buatTugasContoh(jumlah: 1).single;
      expect(t.kunciPencarian, 'tugas praktikum 0001 pemrograman mobile');
    });
  });

  group('saringTugas', () {
    final sumber = buatTugasContoh();

    test('kriteria kosong mengembalikan seluruh data', () {
      expect(saringTugas(sumber, const KriteriaFilter()), hasLength(1000));
    });

    test(
      'pencarian tidak peka huruf besar-kecil dan mengabaikan spasi tepi',
      () {
        final hasil = saringTugas(
          sumber,
          const KriteriaFilter(kueri: '  TUGAS PRAKTIKUM 0002 '),
        );
        expect(hasil.map((t) => t.nomor), <int>[2]);
      },
    );

    test('status dan kueri digabung dengan logika DAN', () {
      final hasil = saringTugas(
        sumber,
        const KriteriaFilter(kueri: 'basis data', status: StatusTugas.selesai),
      );
      expect(hasil, isNotEmpty);
      expect(
        hasil.every((t) => t.selesai && t.mataKuliah == 'Basis Data'),
        isTrue,
      );
    });

    test('penyaringan tidak mengubah daftar sumber', () {
      saringTugas(sumber, const KriteriaFilter(status: StatusTugas.aktif));
      expect(sumber, hasLength(1000));
    });

    test('salinDengan(hapusStatus: true) kembali ke semua status', () {
      const awal = KriteriaFilter(kueri: 'x', status: StatusTugas.aktif);
      final baru = awal.salinDengan(hapusStatus: true);
      expect(baru.status, isNull);
      expect(baru.kueri, 'x');
    });
  });

  testWidgets(
    'daftar memakai builder dan tidak membuat seribu kartu sekaligus',
    (tester) async {
      await tester.pumpWidget(const Modul11App());
      expect(find.text('Menampilkan 1000 dari 1000 tugas'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('task-card-1')), findsOneWidget);
      expect(find.byType(Card).evaluate().length, lessThan(1000));
    },
  );

  testWidgets('pencarian membatasi daftar tanpa mengubah sumber data', (
    tester,
  ) async {
    await tester.pumpWidget(const Modul11App());
    await tester.enterText(
      find.byKey(const ValueKey<String>('task-search')),
      'tugas praktikum 0002',
    );
    await tester.pump();
    expect(find.text('Menampilkan 1 dari 1000 tugas'), findsOneWidget);
    expect(find.text('Tugas praktikum 0002'), findsOneWidget);
  });

  testWidgets('filter status menampilkan hanya tugas selesai', (tester) async {
    await tester.pumpWidget(const Modul11App());
    await tester.tap(find.widgetWithText(FilterChip, 'Selesai'));
    await tester.pump();
    expect(find.text('Menampilkan 250 dari 1000 tugas'), findsOneWidget);
    expect(find.text('Tugas praktikum 0004'), findsOneWidget);
  });

  testWidgets('daftar dapat digulir sampai tugas terakhir', (tester) async {
    await tester.pumpWidget(const Modul11App());
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('task-card-1000')),
      2000,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey<String>('task-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Tugas praktikum 1000'), findsOneWidget);
  });

  testWidgets('kueri tanpa hasil menampilkan state kosong', (tester) async {
    await tester.pumpWidget(const Modul11App());
    await tester.enterText(
      find.byKey(const ValueKey<String>('task-search')),
      'tidak-ada',
    );
    await tester.pump();
    expect(find.text('Tidak ada tugas yang cocok.'), findsOneWidget);
  });
}
