/// Pembatas laju permintaan berbasis jendela bergulir (*sliding window*).
///
/// Dipakai untuk mencegah aplikasi mengirim permintaan lebih cepat daripada
/// yang diizinkan penyedia. Jam disuntikkan lewat [sekarang] supaya perilakunya
/// dapat diuji tanpa menunggu waktu nyata.
class PenjagaKuota {
  PenjagaKuota({
    required this.batas,
    required this.jendela,
    DateTime Function()? sekarang,
  }) : _sekarang = sekarang ?? DateTime.now;

  /// Jumlah permintaan maksimum di dalam satu [jendela].
  final int batas;

  /// Panjang jendela waktu.
  final Duration jendela;

  final DateTime Function() _sekarang;
  final List<DateTime> _riwayat = <DateTime>[];

  /// Membuang catatan yang sudah keluar dari jendela berjalan.
  void _bersihkan() {
    final DateTime ambang = _sekarang().subtract(jendela);
    _riwayat.removeWhere((DateTime t) => t.isBefore(ambang));
  }

  /// Apakah satu permintaan masih boleh dikirim saat ini.
  bool bolehKirim() {
    _bersihkan();
    return _riwayat.length < batas;
  }

  /// Sisa permintaan yang masih diizinkan pada jendela berjalan.
  int get sisa {
    _bersihkan();
    final int hasil = batas - _riwayat.length;
    return hasil < 0 ? 0 : hasil;
  }

  /// Mencatat satu permintaan.
  ///
  /// Panggil hanya setelah [bolehKirim] bernilai benar.
  void catat() {
    _bersihkan();
    _riwayat.add(_sekarang());
  }

  /// Lama tunggu sampai satu slot kembali tersedia.
  ///
  /// Mengembalikan [Duration.zero] bila masih ada slot.
  Duration tungguSampai() {
    _bersihkan();
    if (_riwayat.length < batas) return Duration.zero;
    final DateTime bebas = _riwayat.first.add(jendela);
    final Duration sisaWaktu = bebas.difference(_sekarang());
    return sisaWaktu.isNegative ? Duration.zero : sisaWaktu;
  }

  /// Mengosongkan riwayat, misalnya saat pengguna menekan "coba lagi".
  void reset() => _riwayat.clear();
}
