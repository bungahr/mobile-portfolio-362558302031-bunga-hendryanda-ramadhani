import '../domain/galat_ai.dart';
import '../domain/kontrak_layanan_ai.dart';
import '../domain/penjaga_kuota.dart';

/// Layanan AI tiruan yang berjalan sepenuhnya di perangkat.
///
/// Ia tidak memanggil jaringan dan tidak memerlukan kunci API, sehingga
/// praktikum dapat dijalankan di mana saja dan hasilnya dapat diulang. Bentuk
/// kontraknya sama persis dengan layanan awan, sehingga penggantian penyedia
/// nanti tidak menyentuh lapisan tampilan.
class LayananAiLokal implements LayananAi {
  LayananAiLokal({
    this.jedaPerPotongan = const Duration(milliseconds: 40),
    PenjagaKuota? penjaga,
    this.simulasiGagal = false,
  }) : penjaga = penjaga ??
            PenjagaKuota(batas: 5, jendela: const Duration(minutes: 1));

  /// Jeda antar potongan; dapat dipersingkat di dalam uji.
  final Duration jedaPerPotongan;

  /// Pembatas laju permintaan.
  final PenjagaKuota penjaga;

  /// Bila benar, permintaan pertama gagal seolah-olah jaringan terputus.
  ///
  /// Keadaan gagal harus dapat dibuktikan, bukan sekadar dibayangkan.
  final bool simulasiGagal;

  @override
  String get nama => 'Lokal (di perangkat)';

  @override
  Stream<String> kirim(String perintah) async* {
    if (!penjaga.bolehKirim()) {
      throw const GalatAi(SebabGalat.batasKuota);
    }
    penjaga.catat();

    if (simulasiGagal) {
      throw const GalatAi(SebabGalat.jaringan, detail: 'simulasi praktikum');
    }

    for (final String potongan in potongJawaban(jawabanUntuk(perintah))) {
      await Future<void>.delayed(jedaPerPotongan);
      yield potongan;
    }
  }

  @override
  void tutup() {
    // Layanan lokal tidak memegang sumber daya luar, sehingga tidak ada yang
    // perlu ditutup. Metodenya tetap ada agar memenuhi kontrak.
  }

  static const Map<String, String> _jawaban = <String, String>{
    'dispose':
        'Sumber daya dibersihkan di dalam dispose() agar controller dan subscription tidak bocor memori.',
    'state':
        'State adalah data yang berubah saat pengguna berinteraksi, dan disimpan di dalam objek State.',
    'async':
        'Kata kunci async menandai fungsi yang mengembalikan Future; await menunggu hasilnya tanpa memblokir antarmuka.',
    'kuota':
        'Batas kuota dijaga dengan menghitung permintaan di dalam jendela waktu tertentu sebelum mengirim yang baru.',
    'privasi':
        'Data sensitif disamarkan sebelum dikirim, dan pengguna diberi tahu bahwa jawaban dihasilkan oleh AI.',
  };

  /// Jawaban contoh yang dipilih berdasarkan kata kunci pada [perintah].
  ///
  /// Bersifat murni (tidak bergantung waktu atau acak) supaya hasilnya dapat
  /// diuji dan diulang.
  static String jawabanUntuk(String perintah) {
    final String bersih = perintah.trim().toLowerCase();
    if (bersih.isEmpty) {
      return 'Tuliskan pertanyaan Anda terlebih dahulu.';
    }
    for (final MapEntry<String, String> e in _jawaban.entries) {
      if (bersih.contains(e.key)) return e.value;
    }
    return 'Belum ada jawaban khusus untuk pertanyaan itu. '
        'Coba sebutkan kata kunci seperti dispose, state, async, kuota, atau privasi.';
  }

  /// Memecah [teks] menjadi potongan per kata, mempertahankan spasi.
  ///
  /// Bentuk potongan inilah yang membuat jawaban dapat ditampilkan bertahap,
  /// meniru perilaku aliran dari layanan awan.
  static List<String> potongJawaban(String teks) {
    final List<String> kata = teks.split(' ');
    final List<String> hasil = <String>[];
    for (int i = 0; i < kata.length; i++) {
      hasil.add(i == kata.length - 1 ? kata[i] : '${kata[i]} ');
    }
    return hasil;
  }
}
