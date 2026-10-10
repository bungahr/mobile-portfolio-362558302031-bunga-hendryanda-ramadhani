import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:modul_05_tugas_praktikum/pengayaan/modul_05/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
  });

  test('Migrasi versi 2 ke 3 menjaga data lama dan menambah catatan', () async {
    // Membuat folder sementara untuk database pengujian.
    final Directory folderSementara = await Directory.systemTemp.createTemp(
      'modul05_migrasi_v2_v3_',
    );

    final String jalur =
        '${folderSementara.path}'
        '${Platform.pathSeparator}migrasi.db';

    AppDatabase? penyimpanan;

    try {
      // 1. Membuat database versi 2 terlebih dahulu.
      final Database dbLama = await databaseFactoryFfi.openDatabase(
        jalur,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (Database db, int versi) async {
            await db.execute('''
                CREATE TABLE tugas (
                  id TEXT PRIMARY KEY,
                  judul TEXT NOT NULL,
                  mata_kuliah TEXT NOT NULL,
                  selesai INTEGER NOT NULL DEFAULT 0,
                  dibuat_pada TEXT NOT NULL,
                  prioritas INTEGER NOT NULL DEFAULT 2
                )
              ''');
          },
        ),
      );

      // 2. Memasukkan satu tugas lama.
      await dbLama.insert('tugas', <String, Object?>{
        'id': 'lama-1',
        'judul': 'Tugas lama',
        'mata_kuliah': 'Pemrograman Perangkat Bergerak',
        'selesai': 0,
        'dibuat_pada': '2026-10-01',
        'prioritas': 1,
      });

      await dbLama.close();

      // 3. Membuka database yang sama dengan versi 3.
      penyimpanan = AppDatabase(pabrik: databaseFactoryFfi, jalur: jalur);

      final Database dbBaru = await penyimpanan.basisData;

      // 4. Memeriksa apakah tugas lama masih ada.
      final List<Map<String, Object?>> baris = await dbBaru.query(
        AppDatabase.tabelTugas,
      );

      expect(baris, hasLength(1));
      expect(baris.first['id'], 'lama-1');
      expect(baris.first['judul'], 'Tugas lama');
      expect(baris.first['prioritas'], 1);

      // 5. Memastikan kolom baru sudah ditambahkan.
      final List<Map<String, Object?>> kolom = await dbBaru.rawQuery(
        'PRAGMA table_info(${AppDatabase.tabelTugas})',
      );

      final List<Object?> namaKolom = kolom
          .map((Map<String, Object?> kolom) => kolom['name'])
          .toList();

      expect(namaKolom, contains('prioritas'));
      expect(namaKolom, contains('catatan'));

      // 6. Kolom catatan harus memiliki nilai default kosong.
      expect(baris.first['catatan'], '');

      await penyimpanan.tutup();
      penyimpanan = null;
    } finally {
      // Membersihkan database sementara setelah test.
      if (penyimpanan != null) {
        await penyimpanan.tutup();
      }

      if (await folderSementara.exists()) {
        await folderSementara.delete(recursive: true);
      }
    }
  });
}
