import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'package:modul_07/modul_07/domain/tugas.dart';
import 'package:modul_07/pengayaan/modul_07/data/repositori_tugas_prefs.dart';

base class PenyimpananPrefsPalsu extends SharedPreferencesAsyncPlatform {
  final Map<String, Object> data = {};

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async => data[key] as String?;

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    data[key] = value;
  }

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async =>
      data[key] as bool?;

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    data[key] = value;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async => data[key] as double?;

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    data[key] = value;
  }

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async =>
      data[key] as int?;

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    data[key] = value;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async => (data[key] as List<String>?)?.toList();

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    data[key] = value.toList();
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    data.clear();
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async => Map<String, Object>.from(data);

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async => data.keys.toSet();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PenyimpananPrefsPalsu penyimpanan;
  late SharedPreferencesAsync prefs;
  late RepositoriTugasPrefs repositori;

  setUp(() {
    penyimpanan = PenyimpananPrefsPalsu();
    SharedPreferencesAsyncPlatform.instance = penyimpanan;
    prefs = SharedPreferencesAsync();

    repositori = RepositoriTugasPrefs(prefs, jam: () => '2026-10-28');
  });

  group('Tes persistensi repository', () {
    test('Tugas yang ditambahkan bisa dimuat kembali', () async {
      final Tugas tugas = await repositori.tambah(
        judul: 'Belajar persistensi',
        mataKuliah: 'Pemrograman Perangkat Bergerak',
        prioritas: 1,
      );

      final daftar = await repositori.muatSemua();

      expect(daftar, hasLength(1));
      expect(daftar.first.id, tugas.id);
      expect(daftar.first.judul, 'Belajar persistensi');
      expect(daftar.first.mataKuliah, 'Pemrograman Perangkat Bergerak');
      expect(daftar.first.prioritas, 1);
    });

    test('Perubahan status dan penghapusan tersimpan', () async {
      final Tugas tugas = await repositori.tambah(
        judul: 'Uji status',
        mataKuliah: 'TRPL',
      );

      await repositori.ubahStatus(tugas);

      var daftar = await repositori.muatSemua();
      expect(daftar.single.selesai, isTrue);

      await repositori.hapus(tugas.id);

      daftar = await repositori.muatSemua();
      expect(daftar, isEmpty);
    });
  });
}
