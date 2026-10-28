import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';

class HasilTandaiSemuaSelesai {
  const HasilTandaiSemuaSelesai({
    required this.jumlahDiperbarui,
    required this.kegagalan,
  });

  final int jumlahDiperbarui;
  final List<Kegagalan> kegagalan;

  bool get berhasilPenuh => kegagalan.isEmpty;
}

class TandaiSemuaSelesai {
  const TandaiSemuaSelesai(this.repositori);

  final RepositoriTugas repositori;

  Future<HasilTandaiSemuaSelesai> panggil(List<Tugas> daftar) async {
    var jumlahDiperbarui = 0;
    final List<Kegagalan> kegagalan = [];

    for (final tugas in daftar) {
      if (tugas.selesai) continue;

      try {
        await repositori.ubahStatus(tugas.salinDengan(selesai: true));
        jumlahDiperbarui++;
      } on Kegagalan catch (k) {
        kegagalan.add(k);
      } catch (_) {
        kegagalan.add(const SumberDataGagal());
      }
    }

    return HasilTandaiSemuaSelesai(
      jumlahDiperbarui: jumlahDiperbarui,
      kegagalan: List.unmodifiable(kegagalan),
    );
  }
}
