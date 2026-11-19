// KUNCI LATIHAN 2 (Modul 10): sisa waktu tunggu dalam pesan kegagalan.
//
// Fungsi murni: dihitung SEKALI ketika kegagalan ditampilkan, bukan oleh
// pengatur waktu yang berdetak setiap detik. Karena murni, ia diuji tanpa
// menunggu waktu sungguhan.

/// Menyusun pesan kuota habis dari [tunggu] (hasil `PenjagaKuota.tungguSampai`).
///
/// Detik dibulatkan ke atas: "Coba lagi dalam 0 detik" padahal masih harus
/// menunggu 400 ms akan membuat pengguna menekan tombol yang masih gagal.
String pesanKuotaHabis(Duration tunggu) {
  if (tunggu <= Duration.zero) {
    return 'Kuota sudah tersedia kembali. Silakan coba lagi.';
  }
  final int detik = (tunggu.inMilliseconds / 1000).ceil();
  if (detik < 60) {
    return 'Kuota habis. Coba lagi dalam $detik detik.';
  }
  final int menit = detik ~/ 60;
  final int sisaDetik = detik % 60;
  final String bagianDetik = sisaDetik == 0 ? '' : ' $sisaDetik detik';
  return 'Kuota habis. Coba lagi dalam $menit menit$bagianDetik.';
}
