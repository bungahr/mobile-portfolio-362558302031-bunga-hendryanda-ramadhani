import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';
import '../core/hasil.dart';

class MuatDaftarTugas {
  const MuatDaftarTugas(this.repositori);

  final RepositoriTugas repositori;

  Future<Hasil<List<Tugas>>> panggil() async {
    try {
      final List<Tugas> daftar = await repositori.muatSemua();
      return Sukses<List<Tugas>>(daftar);
    } on Kegagalan catch (k) {
      return Gagal<List<Tugas>>(k);
    } catch (_) {
      return const Gagal<List<Tugas>>(SumberDataGagal());
    }
  }
}
