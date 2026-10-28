import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';
import '../core/hasil.dart';

class MasukanTambahTugas {
  const MasukanTambahTugas({
    required this.judul,
    this.mataKuliah = '',
    this.prioritas = 2,
  });

  final String judul;

  final String mataKuliah;

  final int prioritas;

  @override
  String toString() =>
      'MasukanTambahTugas("$judul", "$mataKuliah", prioritas: $prioritas)';
}

class TambahTugas {
  const TambahTugas(this.repositori);

  final RepositoriTugas repositori;

  Future<Hasil<Tugas>> panggil(MasukanTambahTugas masukan) async {
    try {
      final Tugas tersimpan = await repositori.tambah(
        judul: masukan.judul,
        mataKuliah: masukan.mataKuliah,
        prioritas: masukan.prioritas,
      );
      return Sukses<Tugas>(tersimpan);
    } on Kegagalan catch (k) {
      return Gagal<Tugas>(k);
    } catch (_) {
      return const Gagal<Tugas>(SumberDataGagal());
    }
  }
}
