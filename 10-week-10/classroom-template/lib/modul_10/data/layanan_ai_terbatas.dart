import '../domain/kontrak_layanan_ai.dart';

/// Penyedia AI sederhana dengan jawaban tetap untuk latihan Modul 10.
class LayananAiTerbatas implements LayananAi {
  /// Jawaban tetap yang diberikan untuk setiap perintah.
  static const String jawaban =
      'Flutter adalah framework dari Google untuk membuat aplikasi '
      'multiplatform menggunakan bahasa pemrograman Dart.';

  /// Nama penyedia layanan.
  @override
  String get nama => 'AI Terbatas (Jawaban Tetap)';

  /// Mengirim perintah dan menghasilkan jawaban tetap.
  @override
  Stream<String> kirim(String perintah) async* {
    yield jawaban;
  }
  // Stream<String> kirim(String perintah) async* {}

  /// Menutup layanan. Aman dipanggil berulang kali.
  @override
  void tutup() {}
}
