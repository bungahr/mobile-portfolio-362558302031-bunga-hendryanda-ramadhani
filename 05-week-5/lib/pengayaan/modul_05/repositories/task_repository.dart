import '../../../modul_05/models/task.dart';

enum SumberDataTugas { sharedPreferences, sqlite }

extension SumberDataTugasLabel on SumberDataTugas {
  String get label {
    switch (this) {
      case SumberDataTugas.sharedPreferences:
        return 'SharedPreferences';
      case SumberDataTugas.sqlite:
        return 'SQLite';
    }
  }
}

abstract class TaskRepository {
  Future<List<Task>> ambilSemua();
  Future<void> tambah(Task tugas);
  Future<void> perbarui(Task tugas);
  Future<void> hapus(String id);
  Future<void> hapusSelesai();
  Future<void> bersihkan();
  Future<int> jumlah();
  Future<void> tutup();
}
