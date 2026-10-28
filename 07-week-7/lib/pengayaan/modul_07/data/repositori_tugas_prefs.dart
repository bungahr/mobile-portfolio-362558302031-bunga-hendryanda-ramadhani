import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../modul_07/domain/kegagalan.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';

class RepositoriTugasPrefs implements RepositoriTugas {
  RepositoriTugasPrefs(this.prefs, {String Function()? jam})
    : _jam = jam ?? _tanggalSistem;

  final SharedPreferencesAsync prefs;
  final String Function() _jam;

  static const String _kunci = 'daftar_tugas_modul_07';

  Future<List<Tugas>> _baca() async {
    final String? json = await prefs.getString(_kunci);

    if (json == null || json.isEmpty) {
      return <Tugas>[];
    }

    final List<dynamic> data = jsonDecode(json) as List<dynamic>;

    return data.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return Tugas(
        id: map['id'] as String,
        judul: map['judul'] as String,
        mataKuliah: map['mataKuliah'] as String,
        selesai: map['selesai'] as bool,
        dibuatPada: map['dibuatPada'] as String,
        prioritas: map['prioritas'] as int,
      );
    }).toList();
  }

  Future<void> _simpan(List<Tugas> daftar) async {
    final String json = jsonEncode(
      daftar
          .map(
            (t) => <String, Object>{
              'id': t.id,
              'judul': t.judul,
              'mataKuliah': t.mataKuliah,
              'selesai': t.selesai,
              'dibuatPada': t.dibuatPada,
              'prioritas': t.prioritas,
            },
          )
          .toList(),
    );

    await prefs.setString(_kunci, json);
  }

  @override
  Future<List<Tugas>> muatSemua() async {
    try {
      return List<Tugas>.unmodifiable(await _baca());
    } on FormatException {
      throw const SumberDataGagal();
    } on TypeError {
      throw const SumberDataGagal();
    }
  }

  @override
  Future<Tugas> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  }) async {
    final String bersih = judul.trim();
    if (bersih.isEmpty) {
      throw const JudulKosong();
    }

    try {
      final daftar = await _baca();
      final tugas = Tugas(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        judul: bersih,
        mataKuliah: mataKuliah.trim().isEmpty ? 'Umum' : mataKuliah.trim(),
        dibuatPada: _jam(),
        prioritas: prioritas.clamp(1, 3),
      );

      await _simpan(<Tugas>[...daftar, tugas]);
      return tugas;
    } on FormatException {
      throw const SumberDataGagal();
    } on TypeError {
      throw const SumberDataGagal();
    }
  }

  @override
  Future<void> ubahStatus(Tugas tugas) async {
    try {
      final daftar = await _baca();
      final index = daftar.indexWhere((t) => t.id == tugas.id);

      if (index < 0) {
        throw TugasTidakDitemukan(tugas.id);
      }

      final baru = List<Tugas>.of(daftar);
      baru[index] = daftar[index].salinDengan(selesai: !daftar[index].selesai);

      await _simpan(baru);
    } on FormatException {
      throw const SumberDataGagal();
    } on TypeError {
      throw const SumberDataGagal();
    }
  }

  @override
  Future<void> hapus(String id) async {
    try {
      final daftar = await _baca();
      final index = daftar.indexWhere((t) => t.id == id);

      if (index < 0) {
        throw TugasTidakDitemukan(id);
      }

      final baru = List<Tugas>.of(daftar)..removeAt(index);
      await _simpan(baru);
    } on FormatException {
      throw const SumberDataGagal();
    } on TypeError {
      throw const SumberDataGagal();
    }
  }

  static String _tanggalSistem() {
    final now = DateTime.now();
    final bulan = now.month.toString().padLeft(2, '0');
    final hari = now.day.toString().padLeft(2, '0');
    return '${now.year}-$bulan-$hari';
  }
}
