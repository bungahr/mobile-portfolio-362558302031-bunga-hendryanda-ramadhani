import '../domain/kontrak_layanan_ai.dart';

/// Dekorator yang memendekkan jawaban dari layanan lain.
///
/// Ia mengimplementasikan kontrak yang sama, sehingga dapat menggantikan
/// layanan mana pun tanpa mengubah lapisan tampilan. Inilah manfaat bergantung
/// pada kontrak, bukan pada kelas konkret: perilaku baru ditambahkan dengan
/// membungkus, bukan dengan menyunting kelas yang sudah ada.
///
/// Perhatikan pertukaran yang terjadi: jawaban menjadi lebih singkat, tetapi
/// sifat bertahapnya hilang karena potongan ditahan sampai batas kata tercapai.
class LayananAiRingkas implements LayananAi {
  LayananAiRingkas(this._sumber, {this.maksKata = 12});

  final LayananAi _sumber;

  /// Jumlah potongan maksimum yang ditampilkan.
  final int maksKata;

  @override
  String get nama => '${_sumber.nama} · ringkas';

  @override
  Stream<String> kirim(String perintah) async* {
    final List<String> buffer = <String>[];
    await for (final String potongan in _sumber.kirim(perintah)) {
      buffer.add(potongan);
      if (buffer.length >= maksKata) break;
    }
    yield buffer.join();
  }

  @override
  void tutup() => _sumber.tutup();
}
