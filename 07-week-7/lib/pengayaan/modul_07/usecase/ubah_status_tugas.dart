import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';
import '../core/hasil.dart';

class UbahStatusTugas {
  const UbahStatusTugas(this.repositori);

  final RepositoriTugas repositori;

  Future<Hasil<void>> panggil(Tugas tugas) async {
    try {
      await repositori.ubahStatus(tugas);
      return const Sukses<void>(null);
    } on Kegagalan catch (k) {
      return Gagal<void>(k);
    } catch (_) {
      return const Gagal<void>(SumberDataGagal());
    }
  }
}
