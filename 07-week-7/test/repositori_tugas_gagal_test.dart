import 'package:flutter_test/flutter_test.dart';

import 'package:modul_07/modul_07/data/repositori_tugas_memori.dart';
import 'package:modul_07/modul_07/data/sumber_tugas_memori.dart';
import 'package:modul_07/modul_07/domain/kegagalan.dart';

void main() {
  group('Tes kegagalan repository', () {
    test('Gagal memuat daftar menghasilkan SumberDataGagal', () async {
      final sumber = SumberTugasMemori();
      final repositori = RepositoriTugasMemori(sumber);

      sumber.gagalSaatMuat = true;

      await expectLater(
        repositori.muatSemua(),
        throwsA(isA<SumberDataGagal>()),
      );
    });

    test('Gagal menambah tugas tidak menyimpan data baru', () async {
      final sumber = SumberTugasMemori();
      final repositori = RepositoriTugasMemori(sumber);
      final jumlahAwal = sumber.jumlahBaris;

      sumber.gagalSaatTulis = true;

      await expectLater(
        repositori.tambah(
          judul: 'Mengerjakan latihan mandiri',
          mataKuliah: 'Pemrograman Perangkat Bergerak',
        ),
        throwsA(isA<SumberDataGagal>()),
      );

      expect(sumber.jumlahBaris, jumlahAwal);
    });
  });
}
