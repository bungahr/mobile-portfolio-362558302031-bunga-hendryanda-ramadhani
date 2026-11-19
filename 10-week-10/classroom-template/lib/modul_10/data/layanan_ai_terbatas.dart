import '../domain/kontrak_layanan_ai.dart';

/// Penyedia AI sederhana dengan jawaban tetap untuk latihan Modul 10.
class LayananAiTerbatas implements LayananAi {
  static const String jawaban =
      'Flutter adalah framework dari Google untuk membuat aplikasi '
      'multiplatform menggunakan bahasa pemrograman Dart.';

  @override
  String get nama => 'AI Terbatas (Jawaban Tetap)';

  @override
  Stream<String> kirim(String perintah) async* {
    final List<String> kata = jawaban.split(' ');

    for (int i = 0; i < kata.length; i++) {
      final String potongan = i == kata.length - 1 ? kata[i] : '${kata[i]} ';
      yield potongan;
    }
  }

  @override
  void tutup() {}
}
