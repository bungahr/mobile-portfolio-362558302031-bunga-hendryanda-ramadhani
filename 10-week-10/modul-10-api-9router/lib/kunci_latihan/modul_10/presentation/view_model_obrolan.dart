import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/galat_ai.dart';
import '../domain/kontrak_layanan_ai.dart';
import '../domain/penapis_aman.dart';
import '../domain/pesan_ai.dart';
import 'status_obrolan.dart';

/// Pengatur keadaan percakapan dengan layanan AI.
///
/// Ia menerima [LayananAi] sebagai kontrak, bukan kelas konkret. Karena itu
/// penyedia dapat ditukar (lokal, ringkas, atau awan) tanpa menyentuh kelas ini.
/// Ia juga memegang satu langganan aliran dan membatalkannya di [dispose],
/// sehingga tidak ada pekerjaan yang tertinggal setelah layar ditutup.
class ViewModelObrolan extends ChangeNotifier {
  ViewModelObrolan({
    required LayananAi layanan,
    PenapisAman penapis = const PenapisAman(),
  })  : _layanan = layanan,
        _penapis = penapis;

  final LayananAi _layanan;
  final PenapisAman _penapis;

  final List<PesanAi> _pesan = <PesanAi>[];
  StatusObrolan _status = const ObrolanKosong();
  StreamSubscription<String>? _langganan;
  Completer<void>? _selesai;

  /// Keadaan percakapan saat ini.
  StatusObrolan get status => _status;

  /// Salinan daftar pesan; pemanggil tidak dapat mengubah keadaan dari luar.
  List<PesanAi> get pesan => List<PesanAi>.unmodifiable(_pesan);

  /// Nama penyedia yang sedang dipakai.
  String get namaPenyedia => _layanan.nama;

  /// Apakah ada permintaan yang sedang berjalan.
  bool get sedangSibuk =>
      _status is ObrolanMenunggu || _status is ObrolanMengalir;

  /// Mengirim [teks] ke layanan dan menampilkan jawabannya secara bertahap.
  Future<void> kirim(String teks) async {
    if (sedangSibuk) return;

    final String bersih = teks.trim();
    if (bersih.isEmpty) return;

    final HasilPenapisan hasil = _penapis.periksa(bersih);
    if (!hasil.diizinkan) {
      _status = ObrolanGagal(
        const GalatAi(SebabGalat.ditolakKeamanan),
        List<PesanAi>.of(_pesan),
      );
      notifyListeners();
      return;
    }

    final String aman = _penapis.samarkan(bersih);
    _pesan
      ..add(PesanAi(peran: PeranPesan.pengguna, isi: aman))
      ..add(const PesanAi(peran: PeranPesan.asisten, isi: ''));
    _status = const ObrolanMenunggu();
    notifyListeners();

    final Completer<void> selesai = Completer<void>();
    _selesai = selesai;

    _langganan = _layanan.kirim(aman).listen(
      (String potongan) {
        _pesan[_pesan.length - 1] = _pesan.last.ditambah(potongan);
        _status = ObrolanMengalir(_pesan.last);
        notifyListeners();
      },
      onError: (Object e) {
        final GalatAi galat =
            e is GalatAi ? e : const GalatAi(SebabGalat.tidakDiketahui);
        // Buang balon asisten yang masih kosong; bila sudah terisi sebagian,
        // biarkan agar pengguna melihat sejauh mana jawaban sempat datang.
        if (_pesan.isNotEmpty && !_pesan.last.dariPengguna && _pesan.last.kosong) {
          _pesan.removeLast();
        }
        _status = ObrolanGagal(galat, List<PesanAi>.of(_pesan));
        notifyListeners();
        if (!selesai.isCompleted) selesai.complete();
      },
      onDone: () {
        _status = ObrolanSiap(List<PesanAi>.of(_pesan));
        notifyListeners();
        if (!selesai.isCompleted) selesai.complete();
      },
      cancelOnError: true,
    );

    await selesai.future;
    _selesai = null;
  }

  /// Membatalkan permintaan yang sedang berjalan.
  Future<void> batal() async {
    final StreamSubscription<String>? langganan = _langganan;
    _langganan = null;
    if (langganan != null) {
      await langganan.cancel();
    }
    if (_selesai != null && !_selesai!.isCompleted) {
      _selesai!.complete();
    }
    _selesai = null;
    if (sedangSibuk) {
      _status = ObrolanSiap(List<PesanAi>.of(_pesan));
      notifyListeners();
    }
  }

  /// Menutup pesan kegagalan tanpa menghapus riwayat percakapan.
  void akuiGalat() {
    if (_status is ObrolanGagal) {
      _status = ObrolanSiap(List<PesanAi>.of(_pesan));
      notifyListeners();
    }
  }

  /// Mengirim ulang pesan pengguna yang terakhir.
  ///
  /// Ekor percakapan yang gagal dibuang lebih dahulu supaya pengiriman ulang
  /// tidak menumpuk pesan yang sama.
  Future<void> ulangi() async {
    if (sedangSibuk) return;
    final int indeks = _pesan.lastIndexWhere((PesanAi m) => m.dariPengguna);
    if (indeks < 0) return;
    final String teks = _pesan[indeks].isi;
    _pesan.removeRange(indeks, _pesan.length);
    _status = ObrolanSiap(List<PesanAi>.of(_pesan));
    notifyListeners();
    await kirim(teks);
  }

  /// Mengosongkan percakapan dan kembali ke keadaan awal.
  void bersihkan() {
    _pesan.clear();
    _status = const ObrolanKosong();
    notifyListeners();
  }

  @override
  void dispose() {
    _langganan?.cancel();
    _langganan = null;
    // Penunggu di dalam [kirim] harus dilepas. Tanpa ini, pemanggil yang
    // menunggu pengiriman akan menggantung selamanya ketika layar ditutup
    // sebelum jawaban selesai — kebocoran yang tidak terlihat di layar, tetapi
    // nyata bagi kode yang menunggunya.
    if (_selesai != null && !_selesai!.isCompleted) {
      _selesai!.complete();
    }
    _selesai = null;
    _layanan.tutup();
    super.dispose();
  }
}
