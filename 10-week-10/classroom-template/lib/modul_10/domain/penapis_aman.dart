/// Hasil pemeriksaan teks sebelum dikirim ke layanan AI.
class HasilPenapisan {
  const HasilPenapisan({required this.diizinkan, this.alasan});

  final bool diizinkan;
  final String? alasan;

  @override
  String toString() =>
      'HasilPenapisan(diizinkan: $diizinkan${alasan == null ? '' : ', $alasan'})';
}

/// Penyaring sederhana untuk data sensitif.
class PenapisAman {
  const PenapisAman();

  static final RegExp _polaKunci = RegExp(
    r'(sk-[A-Za-z0-9]{12,}|AIza[0-9A-Za-z_\-]{20,}|ghp_[A-Za-z0-9]{20,})',
  );
  static final RegExp _polaKartu = RegExp(r'\b(?:\d[ -]?){13,16}\b');
  static final RegExp _polaSurel = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');

  HasilPenapisan periksa(String teks) {
    if (_polaKunci.hasMatch(teks)) {
      return const HasilPenapisan(
        diizinkan: false,
        alasan: 'Teks memuat sesuatu yang menyerupai kunci API.',
      );
    }
    if (_polaKartu.hasMatch(teks)) {
      return const HasilPenapisan(
        diizinkan: false,
        alasan: 'Teks memuat rangkaian yang menyerupai nomor kartu.',
      );
    }
    return const HasilPenapisan(diizinkan: true);
  }

  String samarkan(String teks) =>
      teks.replaceAllMapped(_polaSurel, (Match _) => '[surel disamarkan]');
}
