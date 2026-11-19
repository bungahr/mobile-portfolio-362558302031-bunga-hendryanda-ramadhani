import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_10/data/layanan_ai_lokal.dart';
import 'package:poliwangi_mobile_starter/modul_10/domain/galat_ai.dart';
import 'package:poliwangi_mobile_starter/modul_10/domain/penapis_aman.dart';
import 'package:poliwangi_mobile_starter/modul_10/domain/penjaga_kuota.dart';

void main() {
  group('Pengujian batas kuota', () {
    test('Lima permintaan diterima dan permintaan keenam ditolak', () async {
      final penjaga = PenjagaKuota(
        batas: 5,
        jendela: const Duration(minutes: 1),
      );
      final layanan = LayananAiLokal(penjaga: penjaga);

      for (int i = 1; i <= 5; i++) {
        await layanan.kirim('Pertanyaan ke-$i tentang Flutter').join();
      }

      expect(penjaga.sisa, 0);

      await expectLater(
        layanan.kirim('Pertanyaan keenam tentang Flutter').toList(),
        throwsA(isA<GalatAi>()),
      );

      layanan.tutup();
    });
  });

  group('Pengujian penyaring pesan', () {
    const penapis = PenapisAman();

    test('Kunci API tiruan ditolak', () {
      final hasil = penapis.periksa('Gunakan kunci sk-abcdefghijklmnop123456');

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('kunci API'));
    });

    test('Alamat email disamarkan', () {
      const pesan = 'Hubungi bunga@example.com untuk informasi.';
      final hasil = penapis.periksa(pesan);
      final aman = penapis.samarkan(pesan);

      expect(hasil.diizinkan, isTrue);
      expect(aman, contains('[surel disamarkan]'));
      expect(aman, isNot(contains('bunga@example.com')));
    });

    test('Pertanyaan biasa tetap diizinkan', () {
      final hasil = penapis.periksa('Apa fungsi widget pada Flutter?');

      expect(hasil.diizinkan, isTrue);
      expect(hasil.alasan, isNull);
    });
  });
}
