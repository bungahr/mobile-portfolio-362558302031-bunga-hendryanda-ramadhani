import 'package:flutter_test/flutter_test.dart';
import 'package:modul_06_tugas_praktikum/modul_06/models/sesi_pengguna.dart';
import 'package:modul_06_tugas_praktikum/modul_06/services/auth_api.dart';
import 'package:modul_06_tugas_praktikum/modul_06/services/sesi_memori.dart';

void main() {
  group('SesiPengguna', () {
    test('mengubah sesi menjadi JSON dan kembali', () {
      final sesi = SesiPengguna.contoh(sekarang: DateTime(2026, 10, 28, 10));

      final hasil = SesiPengguna.fromJson(sesi.toJson());

      expect(hasil.email, sesi.email);
      expect(hasil.token, sesi.token);
      expect(hasil.kedaluwarsaPada, sesi.kedaluwarsaPada);
    });

    test('sesi yang sudah melewati batas dinyatakan kedaluwarsa', () {
      final sesi = SesiPengguna.contoh(
        sekarang: DateTime(2026, 10, 28, 10),
        masaBerlaku: const Duration(hours: 1),
      );

      expect(sesi.sudahKedaluwarsa(DateTime(2026, 10, 28, 12)), isTrue);
    });

    test('copyWith dapat memperbarui email', () {
      final sesi = SesiPengguna.contoh();
      final hasil = sesi.copyWith(email: 'baru@trpl.test');

      expect(hasil.email, 'baru@trpl.test');
      expect(hasil.token, sesi.token);
    });
  });

  group('AuthApi', () {
    const api = AuthApi(tunda: Duration.zero);

    test('login dengan akun demo berhasil', () async {
      final sesi = await api.masuk(
        email: AuthApi.emailDemo,
        sandi: AuthApi.sandiDemo,
      );

      expect(sesi.email, AuthApi.emailDemo);
      expect(sesi.token, isNotEmpty);
    });

    test('kredensial salah menghasilkan kode 401', () async {
      await expectLater(
        api.masuk(email: AuthApi.emailDemo, sandi: 'salah123'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 401)),
      );
    });

    test('akun terkunci menghasilkan kode 423', () async {
      await expectLater(
        api.masuk(email: AuthApi.emailTerkunci, sandi: 'belajar123'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 423)),
      );
    });

    test('gangguan server menghasilkan kode 503', () async {
      await expectLater(
        api.masuk(email: AuthApi.emailServerGangguan, sandi: 'belajar123'),
        throwsA(isA<AuthException>().having((e) => e.kode, 'kode', 503)),
      );
    });
  });

  group('SesiMemori', () {
    test('sesi bisa disimpan, dibaca, lalu dihapus', () async {
      final memori = SesiMemori();
      final sesi = SesiPengguna.contoh();

      expect(memori.baca(), isNull);

      await memori.simpan(sesi);
      expect(memori.baca()?.email, sesi.email);
      expect(memori.adaSesi, isTrue);

      await memori.hapus();
      expect(memori.baca(), isNull);
      expect(memori.adaSesi, isFalse);
    });
  });
}
