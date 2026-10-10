import '../../../modul_05/models/task.dart';
import '../../../modul_05/services/task_storage.dart';
import 'task_repository.dart';

class PrefsTaskRepository implements TaskRepository {
  PrefsTaskRepository({TaskStorage? storage})
    : _storage = storage ?? const TaskStorage();

  final TaskStorage _storage;

  @override
  Future<List<Task>> ambilSemua() async {
    return _urutkan(await _storage.muat());
  }

  @override
  Future<void> tambah(Task tugas) async {
    final List<Task> semua = await _storage.muat();
    final List<Task> baru = List<Task>.of(semua)
      ..removeWhere((Task t) => t.id == tugas.id)
      ..add(tugas);
    await _storage.simpan(_urutkan(baru));
  }

  @override
  Future<void> perbarui(Task tugas) async {
    final List<Task> semua = await _storage.muat();
    final List<Task> baru = semua
        .map((Task t) => t.id == tugas.id ? tugas : t)
        .toList(growable: true);
    await _storage.simpan(_urutkan(baru));
  }

  @override
  Future<void> hapus(String id) async {
    final List<Task> semua = await _storage.muat();
    semua.removeWhere((Task t) => t.id == id);
    await _storage.simpan(_urutkan(semua));
  }

  @override
  Future<void> hapusSelesai() async {
    final List<Task> semua = await _storage.muat();
    semua.removeWhere((Task t) => t.done);
    await _storage.simpan(_urutkan(semua));
  }

  @override
  Future<void> bersihkan() async {
    await _storage.simpan(<Task>[]);
  }

  @override
  Future<int> jumlah() async {
    return (await ambilSemua()).length;
  }

  @override
  Future<void> tutup() async {
    // SharedPreferences tidak memerlukan koneksi yang harus ditutup.
  }

  /// Pengurutan dilakukan di Dart karena penyimpanan kunci-nilai tidak punya ORDER BY.
  static List<Task> _urutkan(List<Task> sumber) {
    final List<Task> hasil = List<Task>.of(sumber);
    hasil.sort((Task a, Task b) {
      final int prioritas = a.prioritas.compareTo(b.prioritas);
      if (prioritas != 0) return prioritas;
      return b.createdAt.compareTo(a.createdAt);
    });
    return hasil;
  }
}
