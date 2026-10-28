import 'tugas.dart';

abstract interface class RepositoriTugas {
  Future<List<Tugas>> muatSemua();

  Future<Tugas> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  });

  Future<void> ubahStatus(Tugas tugas);

  Future<void> hapus(String id);
}
