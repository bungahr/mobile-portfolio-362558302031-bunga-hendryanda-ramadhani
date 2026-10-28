import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../core/hasil.dart';

class HapusTugas {
  const HapusTugas(this.repositori);

  final RepositoriTugas repositori;

  Future<Hasil<void>> panggil(String id) async {
    try {
      await repositori.hapus(id);
      return const Sukses<void>(null);
    } on Kegagalan catch (k) {
      return Gagal<void>(k);
    } catch (_) {
      return const Gagal<void>(SumberDataGagal());
    }
  }
}
