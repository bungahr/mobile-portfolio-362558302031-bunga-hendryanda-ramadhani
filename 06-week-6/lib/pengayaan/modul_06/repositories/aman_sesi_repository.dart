import 'dart:convert';

import '../storage/penyimpanan_aman.dart';
import '../storage/penyimpanan_aman_platform.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

class AmanSesiRepository implements SesiRepository {
  AmanSesiRepository({PenyimpananAman? penyimpanan})
    : _penyimpanan = penyimpanan ?? PenyimpananAmanPlatform();

  static const String _kunciSesi = 'sesi_pengguna';
  final PenyimpananAman _penyimpanan;

  @override
  String get nama => 'Secure Storage';

  @override
  String get keterangan =>
      'Sesi disimpan melalui plugin secure storage. Perlindungannya bergantung pada platform dan konfigurasinya.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final data = await _penyimpanan.baca(_kunciSesi);
    if (data == null) return null;

    try {
      return SesiPengguna.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      await hapus();
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) {
    return _penyimpanan.tulis(_kunciSesi, jsonEncode(sesi.toJson()));
  }

  @override
  Future<void> hapus() {
    return _penyimpanan.hapus(_kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    return await _penyimpanan.baca(_kunciSesi) != null;
  }

  @override
  Future<String?> intipMentah() {
    return _penyimpanan.bacaMentah(_kunciSesi);
  }
}
