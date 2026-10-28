import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

class PrefsSesiRepository implements SesiRepository {
  static const String _kunciSesi = 'sesi_pengguna';

  @override
  String get nama => 'SharedPreferences';

  @override
  String get keterangan =>
      'Sesi bertahan setelah aplikasi dibuka kembali, tetapi data tidak dienkripsi oleh repository ini.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kunciSesi);

    if (data == null) return null;

    try {
      return SesiPengguna.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      await hapus();
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kunciSesi);
  }

  @override
  Future<String?> intipMentah() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciSesi);
  }
}
