/// Kontrak layanan AI yang dipakai lapisan tampilan.
///
/// Lapisan tampilan hanya mengenal kontrak ini, bukan penyedia tertentu.
/// Karena itu penyedia dapat diganti (lokal, tiruan, atau layanan awan)
/// tanpa mengubah satu baris pun di dalam widget.
abstract interface class LayananAi {
  /// Nama penyedia, dipakai untuk ditampilkan pada panel diagnostik.
  String get nama;

  /// Mengirim [perintah] dan mengembalikan jawaban sebagai aliran potongan teks.
  ///
  /// Aliran memancarkan potongan dari kiri ke kanan sehingga teks dapat
  /// ditampilkan bertahap. Bila gagal, aliran memancarkan [GalatAi].
  Stream<String> kirim(String perintah);

  /// Menutup sumber daya yang dipegang layanan.
  void tutup();
}
