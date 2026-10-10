import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:modul_05_tugas_praktikum/pengayaan/modul_05/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('Migrasi versi 1 menambahkan kolom prioritas', () async {
    final Directory folder = await Directory.systemTemp.createTemp(
      'modul05_db_',
    );
    final String jalur = '${folder.path}/uji_migrasi.db';

    try {
      final Database databaseLama = await databaseFactoryFfi.openDatabase(
        jalur,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int versi) async {
            await db.execute(AppDatabase.sqlBuatTabelV1);
          },
        ),
      );

      await databaseLama.insert(AppDatabase.tabelTugas, <String, Object?>{
        'id': 'lama-1',
        'judul': 'Tugas sebelum migrasi',
        'mata_kuliah': 'Basis Data',
        'selesai': 0,
        'dibuat_pada': '2026-09-15',
      });
      await databaseLama.close();

      final AppDatabase databaseBaru = AppDatabase(
        pabrik: databaseFactoryFfi,
        jalur: jalur,
      );
      final Database db = await databaseBaru.basisData;
      final List<Map<String, Object?>> kolom = await db.rawQuery(
        'PRAGMA table_info(${AppDatabase.tabelTugas})',
      );
      expect(
        kolom.any((Map<String, Object?> baris) => baris['name'] == 'prioritas'),
        isTrue,
      );

      final List<Map<String, Object?>> data = await db.query(
        AppDatabase.tabelTugas,
      );
      expect(data.single['judul'], 'Tugas sebelum migrasi');
      expect(data.single['prioritas'], 2);
      await databaseBaru.tutup();
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
