import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_11/modul_11/modul_11_app.dart';
import 'package:dosen_modul_11/pengayaan/modul_11/data/sumber_tugas_berhalaman.dart';
import 'package:dosen_modul_11/pengayaan/modul_11/presentation/pengendali_halaman.dart';

void main() {
  // ═════════════════════════════════════════════════════════════════
  // Fase A — data dan aturan penyaringan (unit test, tanpa layar)
  // ═════════════════════════════════════════════════════════════════
  group('data contoh', () {
    test('membuat 1.000 tugas dengan 250 tugas selesai', () {
      final List<TugasPerforma> tugas = buatTugasContoh();
      expect(tugas, hasLength(1000));
      expect(tugas.where((TugasPerforma t) => t.selesai), hasLength(250));
      expect(tugas.first.judul, 'Tugas praktikum 0001');
    });

    test('kunci pencarian dihitung sekali dalam huruf kecil', () {
      final TugasPerforma t = buatTugasContoh(jumlah: 1).single;
      expect(t.kunciPencarian, 'tugas praktikum 0001 pemrograman mobile');
    });
  });

  group('saringTugas', () {
    final List<TugasPerforma> sumber = buatTugasContoh();

    test('kriteria kosong mengembalikan seluruh data', () {
      expect(saringTugas(sumber, const KriteriaFilter()), hasLength(1000));
    });

    test(
      'pencarian tidak peka huruf besar-kecil dan mengabaikan spasi tepi',
      () {
        final List<TugasPerforma> hasil = saringTugas(
          sumber,
          const KriteriaFilter(kueri: '  TUGAS PRAKTIKUM 0002 '),
        );
        expect(hasil.map((TugasPerforma t) => t.nomor), <int>[2]);
      },
    );

    test('status dan kueri digabung dengan logika DAN', () {
      final List<TugasPerforma> hasil = saringTugas(
        sumber,
        const KriteriaFilter(kueri: 'basis data', status: StatusTugas.selesai),
      );
      expect(hasil, isNotEmpty);
      expect(
        hasil.every(
          (TugasPerforma t) => t.selesai && t.mataKuliah == 'Basis Data',
        ),
        isTrue,
      );
    });

    test('penyaringan tidak mengubah daftar sumber', () {
      saringTugas(sumber, const KriteriaFilter(status: StatusTugas.aktif));
      expect(sumber, hasLength(1000));
    });

    test('salinDengan(hapusStatus: true) kembali ke semua status', () {
      const KriteriaFilter awal = KriteriaFilter(
        kueri: 'x',
        status: StatusTugas.aktif,
      );
      final KriteriaFilter baru = awal.salinDengan(hapusStatus: true);
      expect(baru.status, isNull);
      expect(baru.kueri, 'x');
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Fase A — layar
  // ═════════════════════════════════════════════════════════════════
  testWidgets(
    'daftar memakai builder dan tidak membuat seribu kartu sekaligus',
    (WidgetTester tester) async {
      await tester.pumpWidget(const Modul11App());
      expect(find.text('Menampilkan 1000 dari 1000 tugas'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('task-card-1')), findsOneWidget);
      expect(find.byType(Card).evaluate().length, lessThan(1000));
    },
  );

  testWidgets('pencarian membatasi daftar tanpa mengubah sumber data', (
    WidgetTester tester,
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

  testWidgets('filter status menampilkan hanya tugas selesai', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul11App());
    await tester.tap(find.widgetWithText(FilterChip, 'Selesai'));
    await tester.pump();
    expect(find.text('Menampilkan 250 dari 1000 tugas'), findsOneWidget);
    expect(find.text('Tugas praktikum 0004'), findsOneWidget);
  });

  testWidgets('daftar dapat digulir sampai tugas terakhir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul11App());
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('task-card-1000')),
      2000,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey<String>('task-list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Tugas praktikum 1000'), findsOneWidget);
  });

  testWidgets('kueri tanpa hasil menampilkan state kosong', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Modul11App());
    await tester.enterText(
      find.byKey(const ValueKey<String>('task-search')),
      'tidak-ada',
    );
    await tester.pump();
    expect(find.text('Tidak ada tugas yang cocok.'), findsOneWidget);
  });

  // ═════════════════════════════════════════════════════════════════
  // Fase B — pagination
  // ═════════════════════════════════════════════════════════════════
  group('Fase B — PengendaliHalaman', () {
    test('memuat halaman bertahap sampai data habis', () async {
      final PengendaliHalaman p = PengendaliHalaman(
        SumberTugasSimulasi(total: 120, jeda: Duration.zero),
        ukuranHalaman: 50,
      );
      await p.muatBerikutnya();
      expect(p.item, hasLength(50));
      await p.muatBerikutnya();
      await p.muatBerikutnya();
      expect(p.item, hasLength(120));
      expect(p.adaBerikutnya, isFalse);
      await p.muatBerikutnya(); // diabaikan karena data habis
      expect(p.item, hasLength(120));
      p.dispose();
    });

    test('galat menyimpan pesan dan halaman yang sama dicoba ulang', () async {
      final PengendaliHalaman p = PengendaliHalaman(
        SumberTugasSimulasi(
          total: 100,
          jeda: Duration.zero,
          gagalPadaHalaman: <int>{2},
        ),
        ukuranHalaman: 50,
      );
      await p.muatBerikutnya();
      await p.muatBerikutnya();
      expect(p.galat, contains('halaman 2'));
      expect(p.item, hasLength(50));
      await p.muatBerikutnya();
      expect(p.galat, isNull);
      expect(p.item, hasLength(100));
      p.dispose();
    });

    test('panggilan ganda saat masih memuat diabaikan', () async {
      final _SumberTertahan sumber = _SumberTertahan();
      final PengendaliHalaman p = PengendaliHalaman(sumber);
      final Future<void> pertama = p.muatBerikutnya();
      await p.muatBerikutnya();
      expect(sumber.jumlahPermintaan, 1);
      sumber.selesaikan();
      await pertama;
      p.dispose();
    });
  });
}

/// Sumber yang menahan jawaban sampai [selesaikan] dipanggil.
class _SumberTertahan implements SumberTugasBerhalaman {
  final Completer<HalamanTugas> _penahan = Completer<HalamanTugas>();
  int jumlahPermintaan = 0;

  void selesaikan() => _penahan.complete(
    const HalamanTugas(item: <TugasPerforma>[], adaBerikutnya: false),
  );

  @override
  Future<HalamanTugas> ambil({required int halaman, required int ukuran}) {
    jumlahPermintaan++;
    return _penahan.future;
  }
}
