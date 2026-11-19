// KUNCI LATIHAN 4 (Modul 10): mengukur biaya penyamaran.
//
// 200 pertanyaan: 100 memuat alamat surel, 100 tidak. Di antaranya ada
// pertanyaan SAH yang memuat rangkaian angka panjang (nomor resi, nomor
// pesanan) — sengaja, untuk menjawab pertanyaan utama latihan: apakah ada
// pertanyaan sah yang ikut ditolak?

import 'penapis_aman.dart';

class RekapPenyamaran {
  const RekapPenyamaran({
    required this.total,
    required this.ditolak,
    required this.disamarkan,
    required this.lolosUtuh,
    required this.contohDitolak,
  });

  final int total;
  final int ditolak;
  final int disamarkan;
  final int lolosUtuh;
  final List<String> contohDitolak;

  @override
  String toString() => 'Total $total · ditolak $ditolak · disamarkan '
      '$disamarkan · lolos utuh $lolosUtuh';
}

/// Daftar 200 pertanyaan contoh yang deterministik.
List<String> pertanyaanContoh200() {
  const List<String> topik = <String>[
    'cara memakai ListView.builder',
    'beda StatelessWidget dan StatefulWidget',
    'kenapa setState tidak memperbarui layar',
    'contoh Future dan async',
    'cara menyimpan data dengan shared_preferences',
  ];
  final List<String> hasil = <String>[];
  for (int i = 0; i < 100; i++) {
    hasil.add('Halo, saya mhs$i@student.poliwangi.ac.id. '
        'Tolong jelaskan ${topik[i % topik.length]}.');
  }
  for (int i = 0; i < 100; i++) {
    if (i % 10 == 0) {
      // Sah, tetapi memuat 16 digit: menyerupai nomor kartu.
      hasil.add('Paket dengan nomor resi 8800 1234 5678 ${(1000 + i)} '
          'belum sampai, bagaimana menampilkan status pengirimannya?');
    } else {
      hasil.add('Tolong jelaskan ${topik[i % topik.length]} (nomor $i).');
    }
  }
  return hasil;
}

RekapPenyamaran ukurPenyamaran(
  List<String> daftar, {
  PenapisAman penapis = const PenapisAman(),
}) {
  int ditolak = 0, disamarkan = 0, utuh = 0;
  final List<String> contoh = <String>[];
  for (final String p in daftar) {
    if (!penapis.periksa(p).diizinkan) {
      ditolak++;
      if (contoh.length < 3) contoh.add(p);
    } else if (penapis.samarkan(p) != p) {
      disamarkan++;
    } else {
      utuh++;
    }
  }
  return RekapPenyamaran(
    total: daftar.length,
    ditolak: ditolak,
    disamarkan: disamarkan,
    lolosUtuh: utuh,
    contohDitolak: contoh,
  );
}
