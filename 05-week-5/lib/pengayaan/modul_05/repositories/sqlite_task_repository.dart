import 'package:sqflite/sqflite.dart';

import '../../../modul_05/models/task.dart';
import '../database/app_database.dart';
import 'task_repository.dart';

class SqliteTaskRepository implements TaskRepository {
  SqliteTaskRepository({AppDatabase? basisData})
    : _basisData = basisData ?? AppDatabase();

  final AppDatabase _basisData;

  @override
  Future<List<Task>> ambilSemua() async {
    final Database db = await _basisData.basisData;
    final List<Map<String, Object?>> baris = await db.query(
      AppDatabase.tabelTugas,
      orderBy: 'prioritas ASC, dibuat_pada DESC',
    );
    return baris.map(_dariBaris).toList(growable: true);
  }

  @override
  Future<void> tambah(Task tugas) async {
    final Database db = await _basisData.basisData;
    await db.insert(
      AppDatabase.tabelTugas,
      _keBaris(tugas),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> perbarui(Task tugas) async {
    final Database db = await _basisData.basisData;
    final int jumlahDiubah = await db.update(
      AppDatabase.tabelTugas,
      _keBaris(tugas),
      where: 'id = ?',
      whereArgs: <Object?>[tugas.id],
    );
    if (jumlahDiubah == 0) {
      await db.insert(AppDatabase.tabelTugas, _keBaris(tugas));
    }
  }

  @override
  Future<void> hapus(String id) async {
    final Database db = await _basisData.basisData;
    await db.delete(
      AppDatabase.tabelTugas,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  @override
  Future<void> hapusSelesai() async {
    final Database db = await _basisData.basisData;
    await db.delete(
      AppDatabase.tabelTugas,
      where: 'selesai = ?',
      whereArgs: <Object?>[1],
    );
  }

  @override
  Future<void> bersihkan() async {
    final Database db = await _basisData.basisData;
    await db.delete(AppDatabase.tabelTugas);
  }

  @override
  Future<int> jumlah() async {
    final Database db = await _basisData.basisData;
    final List<Map<String, Object?>> hasil = await db.rawQuery(
      'SELECT COUNT(*) AS jumlah FROM ${AppDatabase.tabelTugas}',
    );
    return Sqflite.firstIntValue(hasil) ?? 0;
  }

  @override
  Future<void> tutup() => _basisData.tutup();

  static Map<String, Object?> _keBaris(Task tugas) {
    return <String, Object?>{
      'id': tugas.id,
      'judul': tugas.title,
      'mata_kuliah': tugas.course,
      'selesai': tugas.done ? 1 : 0,
      'dibuat_pada': tugas.createdAt,
      'prioritas': tugas.prioritas,
    };
  }

  static Task _dariBaris(Map<String, Object?> baris) {
    return Task(
      id: baris['id']! as String,
      title: baris['judul']! as String,
      course: baris['mata_kuliah']! as String,
      done: (baris['selesai'] as int? ?? 0) == 1,
      createdAt: baris['dibuat_pada']! as String,
      prioritas: baris['prioritas'] as int? ?? 2,
    );
  }
}
