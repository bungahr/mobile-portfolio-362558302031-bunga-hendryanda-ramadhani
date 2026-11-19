/// Peran pengirim sebuah pesan di dalam percakapan dengan layanan AI.
enum PeranPesan {
  /// Pesan yang ditulis oleh pengguna aplikasi.
  pengguna,

  /// Pesan yang dihasilkan oleh layanan AI.
  asisten,
}

/// Satu pesan di dalam percakapan, bersifat tetap (*immutable*).
///
/// Objek ini tidak mengenal jaringan, penyimpanan, maupun penyedia AI
/// tertentu. Karena itu ia dapat dipakai oleh Fase A maupun Fase B tanpa
/// perubahan, dan dapat diuji tanpa menjalankan aplikasi.
class PesanAi {
  const PesanAi({
    required this.peran,
    required this.isi,
    this.dibuatPada,
  });

  /// Siapa yang menulis pesan ini.
  final PeranPesan peran;

  /// Isi teks pesan.
  final String isi;

  /// Waktu pesan dibuat; `null` bila belum dicatat.
  final DateTime? dibuatPada;

  /// Apakah pesan ini berasal dari pengguna.
  bool get dariPengguna => peran == PeranPesan.pengguna;

  /// Apakah isi pesan masih kosong.
  bool get kosong => isi.trim().isEmpty;

  /// Salinan dengan sebagian bidang diganti.
  PesanAi salinDengan({String? isi, DateTime? dibuatPada}) => PesanAi(
        peran: peran,
        isi: isi ?? this.isi,
        dibuatPada: dibuatPada ?? this.dibuatPada,
      );

  /// Menambahkan [potongan] ke akhir isi pesan.
  ///
  /// Dipakai saat jawaban AI datang bertahap: setiap potongan disambungkan ke
  /// pesan asisten yang sedang tumbuh.
  PesanAi ditambah(String potongan) => salinDengan(isi: '$isi$potongan');

  @override
  bool operator ==(Object other) =>
      other is PesanAi &&
      other.peran == peran &&
      other.isi == isi &&
      other.dibuatPada == dibuatPada;

  @override
  int get hashCode => Object.hash(peran, isi, dibuatPada);

  @override
  String toString() => 'PesanAi(${peran.name}, ${isi.length} karakter)';
}
