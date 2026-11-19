import 'package:flutter_test/flutter_test.dart';
import 'package:poliwangi_mobile_starter/modul_10/data/layanan_ai_terbatas.dart';
import 'package:poliwangi_mobile_starter/modul_10/domain/kontrak_layanan_ai.dart';
import 'package:poliwangi_mobile_starter/modul_10/presentation/status_obrolan.dart';
import 'package:poliwangi_mobile_starter/modul_10/presentation/view_model_obrolan.dart';

void main() {
  group('Pengujian LayananAiTerbatas', () {
    test('Memenuhi kontrak LayananAi dan memiliki nama', () {
      final layanan = LayananAiTerbatas();

      expect(layanan, isA<LayananAi>());
      expect(layanan.nama, isNotEmpty);

      layanan.tutup();
    });

    test('Dua perintah berbeda menghasilkan jawaban tetap yang sama', () async {
      final layanan = LayananAiTerbatas();

      final jawabanPertama = await layanan.kirim('Apa itu Flutter?').join();
      final jawabanKedua = await layanan.kirim('Apa fungsi widget?').join();

      expect(jawabanPertama, LayananAiTerbatas.jawaban);
      expect(jawabanKedua, LayananAiTerbatas.jawaban);
      expect(jawabanPertama, jawabanKedua);

      layanan.tutup();
    });

    test('tutup dapat dipanggil dua kali tanpa error', () {
      final layanan = LayananAiTerbatas();

      expect(() {
        layanan.tutup();
        layanan.tutup();
      }, returnsNormally);
    });
  });

  test('ViewModelObrolan berhasil memakai LayananAiTerbatas', () async {
    final model = ViewModelObrolan(layanan: LayananAiTerbatas());
    addTearDown(model.dispose);

    await model.kirim('Jelaskan Flutter');

    expect(model.status, isA<ObrolanSiap>());
    expect(model.pesan.last.isi, contains(LayananAiTerbatas.jawaban));
  });
}
