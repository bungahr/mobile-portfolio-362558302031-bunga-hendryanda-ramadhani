/// Hasil pemeriksaan teks sebelum dikirim ke layanan AI.
class HasilPenapisan {
  const HasilPenapisan({required this.diizinkan, this.alasan});

  /// Apakah teks boleh dikirim.
  final bool diizinkan;

  /// Alasan penolakan; `null` bila teks diizinkan.
  final String? alasan;

  @override
  String toString() =>
      'HasilPenapisan(diizinkan: $diizinkan${alasan == null ? '' : ', $alasan'})';
}

/// Penapis sederhana untuk data sensitif sebelum teks dikirim ke layanan AI.
///
/// Ini bukan pengaman menyeluruh, melainkan pengingat yang dapat diuji. Pola
/// yang jelas berbahaya (kunci API, nomor kartu) ditolak lebih dahulu, sehingga
/// kebocoran tidak bergantung sepenuhnya pada disiplin pengguna. Keterbatasannya
/// dinyatakan terbuka: penapis ini mengenali pola, bukan maksud.
class PenapisAman {
  const PenapisAman();

  static final RegExp _polaKunci = RegExp(
    r'(sk-[A-Za-z0-9]{12,}|AIza[0-9A-Za-z_\-]{20,}|ghp_[A-Za-z0-9]{20,})',
  );
  static final RegExp _polaKartu = RegExp(r'\b(?:\d[ -]?){13,16}\b');
  static final RegExp _polaSurel = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');

  /// Memeriksa [teks] dan memutuskan apakah ia boleh dikirim apa adanya.
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

  /// Menyamarkan alamat surel agar teks tetap dapat dikirim tanpa membuka identitas.
  String samarkan(String teks) =>
      teks.replaceAllMapped(_polaSurel, (Match _) => '⟨surel disamarkan⟩');
}
