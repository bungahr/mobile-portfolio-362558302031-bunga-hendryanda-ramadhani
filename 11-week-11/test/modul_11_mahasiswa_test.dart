import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dosen_modul_11/modul_11/data/sumber_tugas_contoh.dart';
import 'package:dosen_modul_11/modul_11/domain/filter_tugas.dart';
import 'package:dosen_modul_11/modul_11/domain/tugas_performa.dart';
import 'package:dosen_modul_11/modul_11/screens/daftar_tugas_performa_screen.dart';

void main() {
  group('Latihan mandiri Modul 11', () {
    test('Filter Basis Data dan selesai menghasilkan 31 tugas', () {
      final semuaTugas = buatTugasContoh();

      final hasil = saringTugas(
        semuaTugas,
        const KriteriaFilter(
          mataKuliah: 'Basis Data',
          status: StatusTugas.selesai,
        ),
      );

      expect(hasil.length, 31);
      expect(
        hasil.every(
          (tugas) =>
              tugas.mataKuliah == 'Basis Data' &&
              tugas.status == StatusTugas.selesai,
        ),
        isTrue,
      );

      // Memastikan data sumber tidak berubah.
      expect(semuaTugas.length, 1000);
    });

    testWidgets('Jumlah hasil berubah ketika mata kuliah dipilih', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: LayarDaftarTugasPerforma()),
      );

      expect(find.text('Menampilkan 1000 dari 1000 tugas'), findsOneWidget);

      final chipBasisData = find.byKey(const ValueKey('filter-mk-Basis Data'));

      await tester.ensureVisible(chipBasisData);
      await tester.tap(chipBasisData);
      await tester.pumpAndSettle();

      expect(find.text('Menampilkan 125 dari 1000 tugas'), findsOneWidget);
    });
  });
}
