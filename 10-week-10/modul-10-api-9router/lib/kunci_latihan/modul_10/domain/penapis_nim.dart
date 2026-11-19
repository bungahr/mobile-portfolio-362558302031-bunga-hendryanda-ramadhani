// KUNCI LATIHAN 3 (Modul 10): pola tambahan beserta batasnya.
//
// Pola dipilih: nomor induk mahasiswa yang DIDAHULUI kata "NIM".
//
// Mengapa harus ada kata "NIM"? Karena angka 8–12 digit saja juga muncul di
// pertanyaan sah: tahun ajaran "20252026", kode kelas, nomor soal. Penapis
// yang menolak semua angka panjang menghalangi pengguna — masalah yang lebih
// besar daripada kebocoran yang dicegahnya.
//
// BATAS (satu kalimat, wajib ditulis mahasiswa):
//   NIM yang ditulis tanpa kata "NIM" di depannya, misalnya "punya saya
//   362155401001", TIDAK tertangkap.

import 'penapis_aman.dart';

class PenapisDenganNim {
  const PenapisDenganNim({this.dasar = const PenapisAman()});

  final PenapisAman dasar;

  static final RegExp _polaNim =
      RegExp(
    // "NIM", boleh diikuti paling banyak dua kata ("NIM saya", "NIM
    // mahasiswa baru"), lalu 8–12 digit.
    r'\bNIM\b(?:\s+[A-Za-z]+){0,2}\s*[:=.]?\s*\d{8,12}\b',
    caseSensitive: false,
  );

  HasilPenapisan periksa(String teks) {
    final HasilPenapisan hasilDasar = dasar.periksa(teks);
    if (!hasilDasar.diizinkan) return hasilDasar;
    if (_polaNim.hasMatch(teks)) {
      return const HasilPenapisan(
        diizinkan: false,
        alasan: 'Teks memuat nomor induk mahasiswa.',
      );
    }
    return hasilDasar;
  }

  String samarkan(String teks) => dasar.samarkan(teks);
}
