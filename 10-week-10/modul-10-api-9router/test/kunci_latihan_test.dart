// Kunci Latihan Mandiri Modul 10 — hanya untuk dosen.
//
//   Latihan 1 — LayananAiTerbatas memenuhi kontrak; ViewModel tidak diubah.
//   Latihan 2 — pesanKuotaHabis() dari PenjagaKuota.tungguSampai().
//   Latihan 3 — PenapisDenganNim: satu uji ditolak, satu uji sah diizinkan.
//   Latihan 4 — pengukuran 200 pertanyaan.
//
// Latihan 5 (ObrolanDibatalkan) dibahas di KUNCI-LATIHAN.md.

import 'package:flutter_test/flutter_test.dart';

import 'package:dosen_modul_10/kunci_latihan/modul_10/data/layanan_ai_terbatas.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/domain/penapis_nim.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/domain/penjaga_kuota.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/domain/pesan_kuota.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/domain/ukur_penyamaran.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/presentation/status_obrolan.dart';
import 'package:dosen_modul_10/kunci_latihan/modul_10/presentation/view_model_obrolan.dart';

void main() {
  group('Latihan 1 — penyedia ketiga', () {
    test('mengalir bertahap dan menyebut di luar cakupan', () async {
      final List<String> potongan =
          await const LayananAiTerbatas().kirim('Resep rendang?').toList();
      expect(potongan.length, greaterThan(3));
      expect(potongan.join(), contains('di luar cakupan'));
    });

    test('ViewModelObrolan memakainya tanpa perubahan', () async {
      final ViewModelObrolan vm =
          ViewModelObrolan(layanan: const LayananAiTerbatas());
      await vm.kirim('Siapa juara liga?');
      expect(vm.status, isA<ObrolanSiap>());
      expect(vm.pesan.last.isi, contains('di luar cakupan'));
      expect(vm.namaPenyedia, startsWith('Terbatas'));
      vm.dispose();
    });
  });

  group('Latihan 2 — sisa waktu tunggu', () {
    test('dihitung dari jam yang disuntikkan, dibulatkan ke atas', () {
      DateTime jam = DateTime(2026, 11, 5, 9);
      final PenjagaKuota kuota = PenjagaKuota(
        batas: 2,
        jendela: const Duration(minutes: 1),
        sekarang: () => jam,
      );
      kuota.catat();
      jam = jam.add(const Duration(seconds: 16, milliseconds: 400));
      kuota.catat();
      expect(kuota.bolehKirim(), isFalse);
      // Permintaan pertama bebas pada 09:01:00 → sisa 43,6 detik → 44.
      expect(pesanKuotaHabis(kuota.tungguSampai()),
          'Kuota habis. Coba lagi dalam 44 detik.');
    });

    test('batas nol dan menit', () {
      expect(pesanKuotaHabis(Duration.zero), contains('tersedia kembali'));
      expect(pesanKuotaHabis(const Duration(seconds: 43)),
          'Kuota habis. Coba lagi dalam 43 detik.');
      expect(pesanKuotaHabis(const Duration(seconds: 90)),
          'Kuota habis. Coba lagi dalam 1 menit 30 detik.');
      expect(pesanKuotaHabis(const Duration(minutes: 2)),
          'Kuota habis. Coba lagi dalam 2 menit.');
    });
  });

  group('Latihan 3 — penapis NIM', () {
    const PenapisDenganNim penapis = PenapisDenganNim();

    test('DITOLAK: NIM yang didahului kata NIM', () {
      expect(penapis.periksa('NIM saya 362155401001, cek nilai').diizinkan,
          isFalse);
      expect(penapis.periksa('nim: 36215540').diizinkan, isFalse);
    });

    test('DIIZINKAN: teks serupa tetapi sah', () {
      expect(penapis.periksa('Apa itu NIM dan berapa digitnya?').diizinkan,
          isTrue);
      expect(penapis.periksa('Tahun ajaran 20252026 mulai kapan?').diizinkan,
          isTrue);
    });

    test('BATAS yang didokumentasikan: NIM tanpa kata NIM lolos', () {
      expect(penapis.periksa('punya saya 362155401001').diizinkan, isTrue);
    });

    test('aturan dasar tetap berlaku lebih dulu', () {
      expect(penapis.periksa('kunci sk-abcdefghijklmnop').alasan,
          contains('kunci API'));
    });
  });

  group('Latihan 4 — biaya penyamaran', () {
    test('200 pertanyaan: 100 disamarkan, 10 sah ikut ditolak', () {
      final List<String> daftar = pertanyaanContoh200();
      expect(daftar, hasLength(200));
      expect(daftar.where((String p) => p.contains('@')), hasLength(100));

      final RekapPenyamaran r = ukurPenyamaran(daftar);
      expect(r.disamarkan, 100);
      expect(r.ditolak, 10);
      expect(r.lolosUtuh, 90);
      // Inilah temuan utamanya: pertanyaan sah tentang nomor resi ditolak
      // karena menyerupai nomor kartu.
      expect(r.contohDitolak.first, contains('nomor resi'));
    });
  });
}
