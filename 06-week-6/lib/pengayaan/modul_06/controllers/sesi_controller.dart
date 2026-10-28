import 'package:flutter/foundation.dart';

import '../../../modul_06/models/sesi_pengguna.dart';
import '../../../modul_06/services/auth_api.dart';
import '../repositories/sesi_repository.dart';

enum StatusSesi { memeriksa, keluar, memproses, masuk, gagal, kedaluwarsa }

class SesiController extends ChangeNotifier {
  SesiController({required this.repository, AuthApi? authApi})
    : _authApi = authApi ?? AuthApi();

  final SesiRepository repository;
  final AuthApi _authApi;

  StatusSesi status = StatusSesi.memeriksa;
  SesiPengguna? sesi;
  String? pesan;

  Future<void> pulihkanSesi() async {
    status = StatusSesi.memeriksa;
    notifyListeners();

    try {
      final data = await repository.baca();

      if (data == null) {
        sesi = null;
        status = StatusSesi.keluar;
      } else if (data.sudahKedaluwarsa(DateTime.now())) {
        await repository.hapus();
        sesi = null;
        status = StatusSesi.kedaluwarsa;
        pesan = 'Sesi kedaluwarsa. Silakan login kembali.';
      } else {
        sesi = data;
        status = StatusSesi.masuk;
      }
    } catch (e) {
      status = StatusSesi.gagal;
      pesan = 'Gagal memeriksa sesi: $e';
    }

    notifyListeners();
  }

  Future<bool> login({required String email, required String sandi}) async {
    status = StatusSesi.memproses;
    pesan = null;
    notifyListeners();

    try {
      final hasil = await _authApi.masuk(email: email, sandi: sandi);
      await repository.simpan(hasil);
      sesi = hasil;
      status = StatusSesi.masuk;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      status = StatusSesi.gagal;
      pesan = e.pesan;
    } catch (e) {
      status = StatusSesi.gagal;
      pesan = 'Login gagal: $e';
    }

    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await repository.hapus();
      sesi = null;
      pesan = null;
      status = StatusSesi.keluar;
    } catch (e) {
      status = StatusSesi.gagal;
      pesan = 'Gagal logout: $e';
    }
    notifyListeners();
  }

  Future<void> perbaruiSesi() async {
    final sesiAktif = sesi;

    if (sesiAktif == null) {
      await pulihkanSesi();
      return;
    }

    if (sesiAktif.sudahKedaluwarsa(DateTime.now())) {
      await repository.hapus();
      sesi = null;
      status = StatusSesi.kedaluwarsa;
      pesan = 'Sesi kedaluwarsa. Silakan login kembali.';
      notifyListeners();
      return;
    }

    status = StatusSesi.memproses;
    notifyListeners();

    try {
      final baru = await _authApi.perbaruiSesi(sesiAktif);
      await repository.simpan(baru);
      sesi = baru;
      status = StatusSesi.masuk;
      pesan = 'Sesi berhasil diperbarui.';
    } on AuthException catch (e) {
      status = StatusSesi.gagal;
      pesan = e.pesan;
    } catch (e) {
      status = StatusSesi.gagal;
      pesan = 'Gagal memperbarui sesi: $e';
    }

    notifyListeners();
  }
}
