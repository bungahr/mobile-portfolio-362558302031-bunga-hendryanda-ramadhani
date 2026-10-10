import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({this.pabrik, this.jalur});

  final DatabaseFactory? pabrik;
  final String? jalur;

  Database? _basisData;

  static const String namaBerkas = 'poliwangi_tugas.db';
  static const String tabelTugas = 'tugas';

  // Versi terbaru setelah Latihan 5.
  static const int versiSkema = 3;

  /// Bentuk tabel versi 1 untuk pengujian migrasi.
  /// Jangan menambahkan kolom prioritas atau catatan di sini.
  static const String sqlBuatTabelV1 =
      '''
    CREATE TABLE $tabelTugas (
      id TEXT PRIMARY KEY,
      judul TEXT NOT NULL,
      mata_kuliah TEXT NOT NULL,
      selesai INTEGER NOT NULL DEFAULT 0,
      dibuat_pada TEXT NOT NULL
    )
  ''';

  /// Migrasi dari versi 1 ke versi 2.
  static const String sqlMigrasiKeV2 =
      'ALTER TABLE $tabelTugas '
      'ADD COLUMN prioritas INTEGER NOT NULL DEFAULT 2';

  /// Migrasi dari versi 2 ke versi 3.
  static const String sqlMigrasiKeV3 =
      "ALTER TABLE $tabelTugas "
      "ADD COLUMN catatan TEXT NOT NULL DEFAULT ''";

  Future<Database> get basisData async {
    final Database? tersimpan = _basisData;

    if (tersimpan != null) {
      return tersimpan;
    }

    // Factory baru diperlukan saat database benar-benar dibuka.
    // Ini membuat aplikasi SharedPreferences bisa dibuka
    // tanpa langsung meminta factory SQLite.
    final DatabaseFactory pabrikAktif = pabrik ?? databaseFactory;

    final String? jalurTersimpan = jalur;

    final String lokasi;

    if (jalurTersimpan != null) {
      lokasi = jalurTersimpan;
    } else {
      final String direktori = await pabrikAktif.getDatabasesPath();

      lokasi = p.join(direktori, namaBerkas);
    }

    final Database dibuka = await pabrikAktif.openDatabase(
      lokasi,
      options: OpenDatabaseOptions(
        version: versiSkema,
        onCreate: _saatDibuat,
        onUpgrade: _saatDinaikkan,
        onConfigure: _saatDikonfigurasi,
      ),
    );

    _basisData = dibuka;

    return dibuka;
  }

  /// Instalasi baru langsung menggunakan skema versi 3.
  Future<void> _saatDibuat(Database db, int versi) async {
    await db.execute('''
      CREATE TABLE $tabelTugas (
        id TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        mata_kuliah TEXT NOT NULL,
        selesai INTEGER NOT NULL DEFAULT 0,
        dibuat_pada TEXT NOT NULL,
        prioritas INTEGER NOT NULL DEFAULT 2,
        catatan TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  /// Database lama dinaikkan secara bertahap.
  Future<void> _saatDinaikkan(Database db, int versiLama, int versiBaru) async {
    // Migrasi versi 1 ke versi 2 tetap dipertahankan.
    if (versiLama < 2 && versiBaru >= 2) {
      await db.execute(sqlMigrasiKeV2);
    }

    // Latihan 5: migrasi versi 2 ke versi 3.
    if (versiLama < 3 && versiBaru >= 3) {
      await db.execute(sqlMigrasiKeV3);
    }
  }

  Future<void> _saatDikonfigurasi(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> tutup() async {
    final Database? tersimpan = _basisData;

    if (tersimpan != null) {
      await tersimpan.close();
      _basisData = null;
    }
  }
}
