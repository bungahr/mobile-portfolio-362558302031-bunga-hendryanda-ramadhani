/// Sebab kegagalan yang mungkin terjadi saat memanggil layanan AI.
enum SebabGalat {
  /// Perangkat tidak memiliki koneksi, atau koneksi terputus di tengah jalan.
  jaringan,

  /// Kuota pemakaian habis, atau permintaan dikirim terlalu sering.
  batasKuota,

  /// Kunci API hilang, kosong, atau tidak sah.
  kunciTidakSah,

  /// Layanan menolak permintaan karena alasan keamanan.
  ditolakKeamanan,

  /// Sebab lain yang belum dikenali.
  tidakDiketahui,
}

/// Kegagalan yang dapat ditampilkan kepada pengguna.
///
/// Setiap jenis membawa pesan yang layak dibaca pengguna. Pesan internal
/// (misalnya jejak tumpukan) tidak pernah diteruskan ke layar.
class GalatAi implements Exception {
  const GalatAi(this.sebab, {this.detail});

  /// Jenis kegagalan.
  final SebabGalat sebab;

  /// Keterangan tambahan untuk pengembang; tidak ditampilkan ke pengguna.
  final String? detail;

  /// Pesan ringkas untuk pengguna, ditulis dalam bahasa yang dapat ditindaklanjuti.
  String get pesanPengguna => switch (sebab) {
        SebabGalat.jaringan =>
          'Tidak dapat menghubungi layanan. Periksa koneksi Anda.',
        SebabGalat.batasKuota =>
          'Kuota permintaan habis. Tunggu sebentar, lalu coba lagi.',
        SebabGalat.kunciTidakSah =>
          'Kunci API tidak sah. Periksa konfigurasi aplikasi.',
        SebabGalat.ditolakKeamanan =>
          'Permintaan ditolak oleh penyaring keamanan.',
        SebabGalat.tidakDiketahui => 'Terjadi kesalahan yang tidak terduga.',
      };

  /// Apakah percobaan ulang masuk akal untuk sebab ini.
  ///
  /// Kegagalan jaringan dan batas kuota bersifat sementara; kunci yang salah
  /// tidak akan berubah hanya karena dicoba lagi.
  bool get layakDiulang =>
      sebab == SebabGalat.jaringan || sebab == SebabGalat.batasKuota;

  @override
  String toString() =>
      'GalatAi(${sebab.name}${detail == null ? '' : ': $detail'})';
}
