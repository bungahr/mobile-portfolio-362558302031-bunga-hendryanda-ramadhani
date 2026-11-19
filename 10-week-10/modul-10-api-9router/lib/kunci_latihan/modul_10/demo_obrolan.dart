import 'dart:async';

import 'data/layanan_ai_lokal.dart';
import 'domain/galat_ai.dart';
import 'domain/penapis_aman.dart';
import 'domain/penjaga_kuota.dart';

/// Demo baris perintah untuk Modul 10.
///
/// Berjalan tanpa Flutter dan tanpa jaringan, sehingga dapat dipakai untuk
/// membuktikan tiga perilaku inti: jawaban mengalir bertahap, kuota membatasi
/// jumlah permintaan, dan penapis menolak data sensitif.
///
/// Jalankan dengan:
/// `dart run lib/modul_10/demo_obrolan.dart`
Future<void> main() async {
  print('=== 1. Aliran jawaban bertahap ===');
  final LayananAiLokal layanan =
      LayananAiLokal(jedaPerPotongan: Duration.zero);
  final StringBuffer buffer = StringBuffer();
  await for (final String potongan in layanan.kirim('jelaskan dispose')) {
    buffer.write(potongan);
  }
  print('Jawaban: ${buffer.toString()}');

  print('');
  print('=== 2. Pembatas kuota (2 permintaan per menit) ===');
  final PenjagaKuota kuota =
      PenjagaKuota(batas: 2, jendela: const Duration(minutes: 1));
  final LayananAiLokal terbatas =
      LayananAiLokal(penjaga: kuota, jedaPerPotongan: Duration.zero);
  for (int i = 1; i <= 3; i++) {
    try {
      await terbatas.kirim('state').toList();
      print('Permintaan $i: berhasil — sisa kuota ${kuota.sisa}');
    } on GalatAi catch (e) {
      print('Permintaan $i: gagal — ${e.pesanPengguna}');
    }
  }

  print('');
  print('=== 3. Penapis data sensitif ===');
  const PenapisAman penapis = PenapisAman();
  const List<String> contoh = <String>[
    'jelaskan state',
    'kunci saya sk-abcdefghijklmnop',
    'hubungi budi@kampus.ac.id',
  ];
  for (final String teks in contoh) {
    final HasilPenapisan hasil = penapis.periksa(teks);
    final String putusan =
        hasil.diizinkan ? 'diizinkan' : 'DITOLAK — ${hasil.alasan}';
    print('"$teks" -> $putusan');
  }
  print('Setelah disamarkan: ${penapis.samarkan('hubungi budi@kampus.ac.id')}');
}
