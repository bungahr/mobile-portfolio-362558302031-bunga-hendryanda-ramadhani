// KUNCI LATIHAN 1 (Modul 10): penyedia ketiga yang menolak menjawab.
//
// Kelas ini memenuhi kontrak LayananAi dan tidak menyentuh ViewModel sama
// sekali. Bila menambah penyedia membuat Anda ingin menyunting
// view_model_obrolan.dart, kontraknya yang perlu ditinjau.

import '../domain/kontrak_layanan_ai.dart';

class LayananAiTerbatas implements LayananAi {
  const LayananAiTerbatas({
    this.cakupan = 'materi pemrograman mobile',
  });

  /// Apa yang menjadi cakupan asisten; muncul di jawaban penolakan.
  final String cakupan;

  @override
  String get nama => 'Terbatas (menolak di luar cakupan)';

  /// Tetap mengalir per kata supaya perilaku antarmuka sama dengan penyedia
  /// lain: indikator mengetik, tombol hentikan, dan gelembung yang tumbuh.
  @override
  Stream<String> kirim(String perintah) async* {
    final String jawaban = 'Maaf, pertanyaan itu di luar cakupan saya. '
        'Saya hanya dapat membantu $cakupan.';
    for (final String kata in jawaban.split(' ')) {
      yield '$kata ';
    }
  }

  @override
  void tutup() {}
}
