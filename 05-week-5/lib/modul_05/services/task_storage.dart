import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  const TaskStorage({this.tunda = Duration.zero});

  static const String kunciTugas = 'modul_05_tugas';
  static const String kunciVersi = 'modul_05_versi_skema';
  static const String kunciWaktuSimpan = 'modul_05_waktu_simpan';
  static const String kunciCadangan = 'modul_05_tugas_cadangan_rusak';

  static const int versiSkema = 1;

  // Latihan 3: counter selama aplikasi berjalan.
  static int jumlahTugasDitulis = 0;

  // Latihan 4: pesan setelah data rusak berhasil dicadangkan.
  static String? pesanPemulihan;

  final Duration tunda;

  Future<List<Task>> muat({bool pulihkanJsonRusak = false}) async {
    pesanPemulihan = null;

    if (tunda > Duration.zero) {
      await Future<void>.delayed(tunda);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? mentah = prefs.getString(kunciTugas);

    // Kunjungan pertama: tampilkan data contoh.
    if (mentah == null) {
      return List<Task>.of(Task.getSampleTasks());
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(mentah);
    } on FormatException {
      // Perilaku utama Fase A tetap menampilkan error.
      if (!pulihkanJsonRusak) {
        throw const FormatException(
          'Data tugas tersimpan rusak dan tidak dapat dibaca '
          'sebagai JSON.',
        );
      }

      // Latihan 4: simpan isi JSON rusak sebagai cadangan.
      final bool cadanganBerhasil = await prefs.setString(
        kunciCadangan,
        mentah,
      );

      if (!cadanganBerhasil) {
        throw Exception('Data rusak gagal dicadangkan.');
      }

      // Kosongkan daftar agar tidak membaca data rusak lagi.
      final bool kosongBerhasil = await prefs.setString(kunciTugas, '[]');

      if (!kosongBerhasil) {
        throw Exception('Daftar kosong gagal disimpan.');
      }

      pesanPemulihan = 'Data rusak sudah dicadangkan. Daftar dikosongkan.';

      return <Task>[];
    }

    if (decoded is! List<dynamic>) {
      throw const FormatException(
        'Data tugas tersimpan tidak berbentuk daftar.',
      );
    }

    final List<Task> tugas = <Task>[];

    try {
      for (final dynamic item in decoded) {
        if (item is! Map) {
          throw const FormatException(
            'Ada data tugas yang formatnya tidak sesuai.',
          );
        }

        tugas.add(Task.fromJson(Map<String, dynamic>.from(item)));
      }
    } on TypeError {
      throw const FormatException(
        'Data tugas tersimpan memiliki bentuk yang tidak sesuai.',
      );
    }

    return tugas;
  }

  Future<void> simpan(List<Task> tugas) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String mentah = jsonEncode(
      tugas.map((Task t) => t.toJson()).toList(growable: false),
    );

    final bool berhasil = await prefs.setString(kunciTugas, mentah);

    if (!berhasil) {
      throw Exception('Penyimpanan perangkat menolak penulisan data tugas.');
    }

    // Latihan 3: hitung record setelah daftar berhasil ditulis.
    jumlahTugasDitulis += tugas.length;

    // Latihan 2: simpan waktu setelah daftar berhasil ditulis.
    final bool waktuBerhasil = await prefs.setString(
      kunciWaktuSimpan,
      DateTime.now().toIso8601String(),
    );

    if (!waktuBerhasil) {
      throw Exception('Waktu penyimpanan gagal dicatat.');
    }

    final bool versiBerhasil = await prefs.setInt(kunciVersi, versiSkema);

    if (!versiBerhasil) {
      throw Exception('Versi penyimpanan gagal dicatat.');
    }
  }

  // Latihan 2: membaca waktu penyimpanan terakhir.
  Future<DateTime?> bacaWaktuSimpan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? mentah = prefs.getString(kunciWaktuSimpan);

    if (mentah == null) return null;

    return DateTime.tryParse(mentah);
  }

  Future<void> hapusSemua() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(kunciTugas);
    await prefs.remove(kunciVersi);
    await prefs.remove(kunciWaktuSimpan);
    await prefs.remove(kunciCadangan);

    pesanPemulihan = null;
  }

  /// Membuat data rusak untuk menguji keadaan gagal.
  Future<void> rusakkanUntukDemo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(kunciTugas, '{ini sengaja bukan JSON yang sah');
  }

  /// Dipakai test bawaan untuk mereset data tiruan.
  static void resetMemoryForTest() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(<String, Object>{});

    jumlahTugasDitulis = 0;
    pesanPemulihan = null;
  }
}
