import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_11/modul_11/domain/tugas_performa.dart';
import 'package:dosen_modul_11/pengayaan/modul_11/data/sumber_tugas_berhalaman.dart';
import 'package:dosen_modul_11/pengayaan/modul_11/presentation/pengendali_halaman.dart';

void main() {
  group('Fase B — PengendaliHalaman', () {
    test('memuat halaman bertahap sampai data habis', () async {
      final p = PengendaliHalaman(
        SumberTugasSimulasi(total: 120, jeda: Duration.zero),
        ukuranHalaman: 50,
      );

      await p.muatBerikutnya();
      expect(p.item, hasLength(50));

      await p.muatBerikutnya();
      await p.muatBerikutnya();

      expect(p.item, hasLength(120));
      expect(p.adaBerikutnya, isFalse);

      await p.muatBerikutnya();
      expect(p.item, hasLength(120));

      p.dispose();
    });

    test('galat menyimpan pesan dan halaman yang sama dicoba ulang', () async {
      final p = PengendaliHalaman(
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
      final sumber = _SumberTertahan();
      final p = PengendaliHalaman(sumber);

      final pertama = p.muatBerikutnya();
      await p.muatBerikutnya();

      expect(sumber.jumlahPermintaan, 1);

      sumber.selesaikan();
      await pertama;

      p.dispose();
    });
  });
}

class _SumberTertahan implements SumberTugasBerhalaman {
  final Completer<HalamanTugas> _penahan = Completer<HalamanTugas>();

  int jumlahPermintaan = 0;

  void selesaikan() {
    _penahan.complete(
      const HalamanTugas(item: <TugasPerforma>[], adaBerikutnya: false),
    );
  }

  @override
  Future<HalamanTugas> ambil({required int halaman, required int ukuran}) {
    jumlahPermintaan++;
    return _penahan.future;
  }
}
