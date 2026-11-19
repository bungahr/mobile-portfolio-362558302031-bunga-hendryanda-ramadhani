// Pengujian Modul 10 — AI Feature Integration.
//
// Struktur berkas ini mengikuti pola Modul 05 sampai Modul 09:
//
//   Bagian 1  — PesanAi: nilai tetap dan kesetaraan
//   Bagian 2  — GalatAi: pesan pengguna dan kelayakan percobaan ulang
//   Bagian 3  — PenjagaKuota: jendela bergulir dengan jam yang disuntikkan
//   Bagian 4  — PenapisAman: menolak sebelum teks dikirim
//   Bagian 5  — LayananAiLokal: aliran, kuota, dan kegagalan yang dibuktikan
//   Bagian 6  — LayananAiRingkas: dekorator yang menjaga kontrak
//   Bagian 7  — ViewModelObrolan: siklus keadaan percakapan
//   Bagian 8  — Widget murni tampilan: gelembung, bilah kuota, pengungkapan
//   Bagian 9  — LayarObrolanAi: uji widget pada permukaan yang tinggi
//   Bagian 10 — ATURAN DEPENDENSI: arah impor antar lapisan, dan kredensial
//
// Empat hal yang membuat modul ini lebih dari sekadar "aplikasinya jalan":
//
//   - Seluruh modul ini berjalan TANPA jaringan dan TANPA kunci API. Itu
//     keputusan desain, bukan kekurangan: praktikum yang butuh kredensial akan
//     gagal di separuh kelas, dan hasilnya tidak dapat diulang. Bagian 5
//     membuktikan bahwa perilaku layanan awan — aliran bertahap, batas kuota,
//     kegagalan jaringan — dapat direproduksi di perangkat.
//   - Bagian 3 menguji pembatas laju dengan jam yang disuntikkan, sehingga
//     "satu menit" diuji dalam mikrodetik. Waktu nyata tidak boleh masuk ke
//     dalam uji; kalau tidak, ujinya menjadi lambat dan kadang gagal.
//   - Bagian 7 menguji SETIAP keadaan, termasuk yang tidak nyaman: pengguna
//     menekan hentikan di tengah jawaban, layar ditutup saat permintaan masih
//     berjalan, dan pengiriman kedua saat permintaan pertama belum selesai.
//   - Bagian 10 mengubah klaim "lapisan tampilan tidak mengenal penyedia
//     konkret" menjadi pemeriksaan yang dijalankan mesin. Klaim arsitektur yang
//     tidak diuji akan basi dalam dua modul.
//
// Seluruh uji berjalan tanpa emulator dan tanpa jaringan. Hanya Bagian 10 yang
// menyentuh sistem berkas, dan hanya untuk membaca berkas sumber yang memang
// ada di repositori.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dosen_modul_10/modul_10/data/layanan_ai_lokal.dart';
import 'package:dosen_modul_10/modul_10/data/layanan_ai_ringkas.dart';
import 'package:dosen_modul_10/modul_10/domain/galat_ai.dart';
import 'package:dosen_modul_10/modul_10/domain/kontrak_layanan_ai.dart';
import 'package:dosen_modul_10/modul_10/domain/penapis_aman.dart';
import 'package:dosen_modul_10/modul_10/domain/penjaga_kuota.dart';
import 'package:dosen_modul_10/modul_10/domain/pesan_ai.dart';
import 'package:dosen_modul_10/modul_10/modul_10_app.dart';
import 'package:dosen_modul_10/modul_10/presentation/status_obrolan.dart';
import 'package:dosen_modul_10/modul_10/presentation/view_model_obrolan.dart';
import 'package:dosen_modul_10/modul_10/screens/layar_obrolan_ai.dart';
import 'package:dosen_modul_10/modul_10/widgets/bilah_kuota.dart';
import 'package:dosen_modul_10/modul_10/widgets/gelembung_pesan.dart';
import 'package:dosen_modul_10/modul_10/widgets/kartu_pengungkapan.dart';

// ---------------------------------------------------------------------------
// Pembantu
// ---------------------------------------------------------------------------

/// Isi berkas tanpa baris komentar.
///
/// Uji arsitektur harus membuang komentar lebih dahulu. Tanpa itu, kata di
/// dalam komentar ikut cocok — dan ujinya menuduh berkas yang sebenarnya bersih.
/// Aturan ini dipelajari pada Modul 09 dan berlaku untuk semua modul.
String tanpaKomentar(File berkas) {
  final List<String> baris = <String>[];
  for (final String b in berkas.readAsLinesSync()) {
    if (b.trimLeft().startsWith('//')) continue;
    baris.add(b);
  }
  return baris.join('\n');
}

/// Membaca daftar URI impor dari sebuah berkas Dart.
///
/// Sengaja membaca **teks berkas** dan bukan hasil analisis kode: cara ini
/// sederhana, tidak butuh alat tambahan, dan justru itulah yang membuatnya
/// dapat dipakai mahasiswa di proyeknya sendiri tanpa memasang apa pun.
List<String> imporDari(File berkas) {
  final List<String> hasil = <String>[];
  for (final String baris in tanpaKomentar(berkas).split('\n')) {
    final String t = baris.trimLeft();
    if (!t.startsWith('import ')) continue;
    final RegExpMatch? cocok = RegExp(r"""['"]([^'"]+)['"]""").firstMatch(t);
    if (cocok != null) hasil.add(cocok.group(1)!);
  }
  return hasil;
}

/// Seluruh berkas `.dart` di bawah [folder], diurutkan agar hasilnya tetap.
List<File> berkasDart(String folder) {
  final List<File> hasil = <File>[];
  for (final FileSystemEntity e in Directory(
    folder,
  ).listSync(recursive: true)) {
    if (e is File && e.path.endsWith('.dart')) hasil.add(e);
  }
  hasil.sort((File a, File b) => a.path.compareTo(b.path));
  return hasil;
}

/// Layanan tiruan yang perilakunya ditentukan uji.
///
/// Dipakai untuk menguji hal yang tidak dapat diperintahkan kepada layanan
/// lokal: menggantung tanpa akhir, gagal dengan sebab tertentu, atau mencatat
/// apakah [tutup] pernah dipanggil.
class LayananPalsu implements LayananAi {
  LayananPalsu({
    this.potongan = const <String>['ha', 'lo'],
    this.galat,
    this.menggantung = false,
  });

  final List<String> potongan;
  final GalatAi? galat;
  final bool menggantung;

  /// Berapa kali [tutup] dipanggil.
  int jumlahTutup = 0;

  /// Berapa kali [kirim] dipanggil.
  int jumlahKirim = 0;

  /// Perintah terakhir yang diterima.
  String? perintahTerakhir;

  @override
  String get nama => 'Palsu';

  @override
  Stream<String> kirim(String perintah) async* {
    jumlahKirim++;
    perintahTerakhir = perintah;
    if (galat != null) throw galat!;
    for (final String p in potongan) {
      yield p;
    }
    if (menggantung) {
      await Completer<void>().future; // tidak pernah selesai
    }
  }

  @override
  void tutup() => jumlahTutup++;
}

/// Memompa sejumlah bingkai tetap agar aliran yang memakai jeda pendek selesai.
///
/// Sengaja tidak memakai `pumpAndSettle`: penggulingan otomatis memanggil
/// `addPostFrameCallback`, dan `pumpAndSettle` dapat berputar tanpa henti pada
/// pola itu. Memompa dalam jumlah terbatas membuat uji ini pasti berhenti.
Future<void> pompaHinggaTenang(WidgetTester tester, {int langkah = 30}) async {
  for (int i = 0; i < langkah; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  // =========================================================================
  // Bagian 1 — PesanAi
  // =========================================================================
  group('Bagian 1 — PesanAi', () {
    test('menyimpan peran, isi, dan waktu', () {
      final DateTime waktu = DateTime(2026, 9, 22, 10, 0);
      final PesanAi pesan = PesanAi(
        peran: PeranPesan.pengguna,
        isi: 'halo',
        dibuatPada: waktu,
      );

      expect(pesan.peran, PeranPesan.pengguna);
      expect(pesan.isi, 'halo');
      expect(pesan.dibuatPada, waktu);
    });

    test('waktu boleh kosong', () {
      const PesanAi pesan = PesanAi(peran: PeranPesan.asisten, isi: 'hai');
      expect(pesan.dibuatPada, isNull);
    });

    test('dariPengguna benar hanya untuk peran pengguna', () {
      const PesanAi a = PesanAi(peran: PeranPesan.pengguna, isi: 'x');
      const PesanAi b = PesanAi(peran: PeranPesan.asisten, isi: 'x');

      expect(a.dariPengguna, isTrue);
      expect(b.dariPengguna, isFalse);
    });

    test('kosong benar untuk teks kosong dan spasi saja', () {
      const PesanAi kosong = PesanAi(peran: PeranPesan.asisten, isi: '');
      const PesanAi spasi = PesanAi(peran: PeranPesan.asisten, isi: '   ');
      const PesanAi berisi = PesanAi(peran: PeranPesan.asisten, isi: 'a');

      expect(kosong.kosong, isTrue);
      expect(spasi.kosong, isTrue);
      expect(berisi.kosong, isFalse);
    });

    test('salinDengan mengganti isi tetapi mempertahankan peran', () {
      const PesanAi asal = PesanAi(peran: PeranPesan.asisten, isi: 'lama');
      final PesanAi salinan = asal.salinDengan(isi: 'baru');

      expect(salinan.isi, 'baru');
      expect(salinan.peran, PeranPesan.asisten);
      expect(asal.isi, 'lama', reason: 'Objek asal tidak boleh berubah.');
    });

    test('salinDengan tanpa argumen menyalin seluruh bidang', () {
      final DateTime waktu = DateTime(2026, 1, 1);
      final PesanAi asal = PesanAi(
        peran: PeranPesan.pengguna,
        isi: 'x',
        dibuatPada: waktu,
      );
      final PesanAi salinan = asal.salinDengan();

      expect(salinan, asal);
      expect(salinan.dibuatPada, waktu);
    });

    test('ditambah menyambungkan potongan ke akhir isi', () {
      const PesanAi asal = PesanAi(peran: PeranPesan.asisten, isi: 'a');
      final PesanAi hasil = asal.ditambah('b').ditambah('c');

      expect(hasil.isi, 'abc');
      expect(hasil.peran, PeranPesan.asisten);
    });

    test('ditambah dari pesan kosong menghasilkan potongan itu sendiri', () {
      const PesanAi asal = PesanAi(peran: PeranPesan.asisten, isi: '');
      expect(asal.ditambah('kata').isi, 'kata');
    });

    test('kesetaraan berlaku untuk bidang yang sama', () {
      const PesanAi a = PesanAi(peran: PeranPesan.pengguna, isi: 'x');
      const PesanAi b = PesanAi(peran: PeranPesan.pengguna, isi: 'x');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('kesetaraan gagal bila isi atau peran berbeda', () {
      const PesanAi a = PesanAi(peran: PeranPesan.pengguna, isi: 'x');
      const PesanAi b = PesanAi(peran: PeranPesan.pengguna, isi: 'y');
      const PesanAi c = PesanAi(peran: PeranPesan.asisten, isi: 'x');

      expect(a, isNot(b));
      expect(a, isNot(c));
    });

    test('toString menyebut peran dan panjang isi', () {
      const PesanAi pesan = PesanAi(peran: PeranPesan.asisten, isi: '1234');
      expect(pesan.toString(), 'PesanAi(asisten, 4 karakter)');
    });
  });

  // =========================================================================
  // Bagian 2 — GalatAi
  // =========================================================================
  group('Bagian 2 — GalatAi', () {
    test('setiap sebab memiliki pesan pengguna yang dapat ditindaklanjuti', () {
      const Map<SebabGalat, String> diharapkan = <SebabGalat, String>{
        SebabGalat.jaringan:
            'Tidak dapat menghubungi layanan. Periksa koneksi Anda.',
        SebabGalat.batasKuota:
            'Kuota permintaan habis. Tunggu sebentar, lalu coba lagi.',
        SebabGalat.kunciTidakSah:
            'Kunci API tidak sah. Periksa konfigurasi aplikasi.',
        SebabGalat.ditolakKeamanan:
            'Permintaan ditolak oleh penyaring keamanan.',
        SebabGalat.tidakDiketahui: 'Terjadi kesalahan yang tidak terduga.',
      };

      for (final MapEntry<SebabGalat, String> e in diharapkan.entries) {
        expect(
          GalatAi(e.key).pesanPengguna,
          e.value,
          reason: 'Pesan untuk ${e.key.name} tidak sesuai.',
        );
      }
      // Lima sebab, lima pesan. Uji ini berteriak saat anggota enum ditambah
      // tetapi pesannya lupa ditulis.
      expect(diharapkan.length, SebabGalat.values.length);
    });

    test('layakDiulang benar untuk kegagalan yang bersifat sementara', () {
      expect(const GalatAi(SebabGalat.jaringan).layakDiulang, isTrue);
      expect(const GalatAi(SebabGalat.batasKuota).layakDiulang, isTrue);
    });

    test('layakDiulang salah untuk kegagalan yang tidak akan berubah', () {
      // Kunci yang salah tidak menjadi benar hanya karena dicoba lagi.
      expect(const GalatAi(SebabGalat.kunciTidakSah).layakDiulang, isFalse);
      expect(const GalatAi(SebabGalat.ditolakKeamanan).layakDiulang, isFalse);
      expect(const GalatAi(SebabGalat.tidakDiketahui).layakDiulang, isFalse);
    });

    test('detail tidak pernah masuk ke pesan pengguna', () {
      const GalatAi galat = GalatAi(
        SebabGalat.jaringan,
        detail: 'SocketException: host tidak ditemukan pada 10.0.2.2:8080',
      );

      expect(galat.detail, contains('SocketException'));
      expect(galat.pesanPengguna, isNot(contains('SocketException')));
      expect(galat.pesanPengguna, isNot(contains('10.0.2.2')));
    });

    test('toString memuat nama sebab dan detail', () {
      expect(
        const GalatAi(SebabGalat.jaringan).toString(),
        'GalatAi(jaringan)',
      );
      expect(
        const GalatAi(SebabGalat.jaringan, detail: 'x').toString(),
        'GalatAi(jaringan: x)',
      );
    });

    test('GalatAi adalah Exception sehingga dapat ditangkap sebagai galat', () {
      expect(const GalatAi(SebabGalat.jaringan), isA<Exception>());
    });
  });

  // =========================================================================
  // Bagian 3 — PenjagaKuota
  // =========================================================================
  group('Bagian 3 — PenjagaKuota', () {
    late DateTime jam;
    late PenjagaKuota kuota;

    setUp(() {
      jam = DateTime(2026, 9, 22, 10, 0, 0);
      kuota = PenjagaKuota(
        batas: 3,
        jendela: const Duration(minutes: 1),
        sekarang: () => jam,
      );
    });

    test('keadaan awal mengizinkan pengiriman dan sisa penuh', () {
      expect(kuota.bolehKirim(), isTrue);
      expect(kuota.sisa, 3);
    });

    test('sisa berkurang setiap kali catat dipanggil', () {
      kuota.catat();
      expect(kuota.sisa, 2);
      kuota.catat();
      expect(kuota.sisa, 1);
      kuota.catat();
      expect(kuota.sisa, 0);
    });

    test('pengiriman ditolak setelah batas tercapai', () {
      kuota
        ..catat()
        ..catat()
        ..catat();

      expect(kuota.bolehKirim(), isFalse);
    });

    test('tungguSampai nol selama masih ada slot', () {
      kuota.catat();
      expect(kuota.tungguSampai(), Duration.zero);
    });

    test('tungguSampai menghitung sisa waktu hingga slot pertama bebas', () {
      kuota
        ..catat()
        ..catat()
        ..catat();

      expect(kuota.tungguSampai(), const Duration(minutes: 1));

      jam = jam.add(const Duration(seconds: 20));
      expect(kuota.tungguSampai(), const Duration(seconds: 40));
    });

    test('slot kembali setelah jendela terlewati', () {
      kuota
        ..catat()
        ..catat()
        ..catat();
      expect(kuota.bolehKirim(), isFalse);

      jam = jam.add(const Duration(seconds: 61));

      expect(kuota.bolehKirim(), isTrue);
      expect(kuota.sisa, 3);
    });

    test('catatan dibuang satu per satu, bukan sekaligus', () {
      // Batasnya dilonggarkan supaya angka yang diperiksa adalah jumlah
      // catatan yang tersisa, bukan selisihnya terhadap batas.
      final PenjagaKuota longgar = PenjagaKuota(
        batas: 10,
        jendela: const Duration(minutes: 1),
        sekarang: () => jam,
      );
      longgar.catat(); // t = 0
      jam = jam.add(const Duration(seconds: 30));
      longgar.catat(); // t = 30
      jam = jam.add(const Duration(seconds: 30));
      longgar.catat(); // t = 60

      // Pada t = 61 hanya catatan t = 0 yang keluar dari jendela. Dua catatan
      // lainnya masih berlaku, sehingga sisa = 10 - 2 = 8. Bila seluruh
      // riwayat dibuang sekaligus, jawabannya akan menjadi 10.
      jam = jam.add(const Duration(seconds: 1));
      expect(longgar.sisa, 8);
    });

    test('jendela tidak pernah membiarkan sisa bernilai negatif', () {
      final PenjagaKuota kecil = PenjagaKuota(
        batas: 1,
        jendela: const Duration(minutes: 1),
        sekarang: () => jam,
      );
      kecil
        ..catat()
        ..catat(); // sengaja melampaui batas

      expect(kecil.sisa, 0);
      expect(kecil.bolehKirim(), isFalse);
    });

    test('reset mengosongkan riwayat', () {
      kuota
        ..catat()
        ..catat()
        ..catat();
      expect(kuota.bolehKirim(), isFalse);

      kuota.reset();

      expect(kuota.bolehKirim(), isTrue);
      expect(kuota.sisa, 3);
    });

    test('tanpa jam yang disuntikkan, pembatas memakai waktu nyata', () {
      final PenjagaKuota nyata = PenjagaKuota(
        batas: 1,
        jendela: const Duration(minutes: 1),
      );
      nyata.catat();

      expect(nyata.bolehKirim(), isFalse);
      expect(nyata.tungguSampai().inSeconds, greaterThan(0));
      expect(nyata.tungguSampai().inSeconds, lessThanOrEqualTo(60));
    });
  });

  // =========================================================================
  // Bagian 4 — PenapisAman
  // =========================================================================
  group('Bagian 4 — PenapisAman', () {
    const PenapisAman penapis = PenapisAman();

    test('teks biasa diizinkan tanpa alasan', () {
      final HasilPenapisan hasil = penapis.periksa('jelaskan cara dispose');

      expect(hasil.diizinkan, isTrue);
      expect(hasil.alasan, isNull);
    });

    test('kunci bergaya sk- ditolak', () {
      final HasilPenapisan hasil = penapis.periksa(
        'kunci saya sk-abcdefghijklmnop',
      );

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('kunci API'));
    });

    test('kunci bergaya AIza ditolak', () {
      final HasilPenapisan hasil = penapis.periksa(
        'pakai AIzaSyA1234567890abcdefghij ya',
      );

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('kunci API'));
    });

    test('token bergaya ghp_ ditolak', () {
      final HasilPenapisan hasil = penapis.periksa(
        'token ghp_abcdefghijklmnopqrst jangan disebar',
      );

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('kunci API'));
    });

    test('rangkaian yang menyerupai nomor kartu ditolak', () {
      final HasilPenapisan hasil = penapis.periksa('4111 1111 1111 1111');

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('nomor kartu'));
    });

    test('tiga belas angka tanpa pemisah sudah ditolak', () {
      expect(penapis.periksa('1234567890123').diizinkan, isFalse);
    });

    test('dua belas angka belum ditolak', () {
      // Batas bawah pola adalah tiga belas angka. Uji ini mengunci batas itu,
      // supaya angka biasa seperti nomor induk mahasiswa tidak ikut ditolak.
      expect(penapis.periksa('123456789012').diizinkan, isTrue);
    });

    test('tanggal tidak dikira nomor kartu', () {
      expect(penapis.periksa('hari ini 2026-09-22').diizinkan, isTrue);
    });

    test('alamat surel tidak ditolak, tetapi disamarkan', () {
      const String teks = 'hubungi budi@kampus.ac.id';

      expect(penapis.periksa(teks).diizinkan, isTrue);
      expect(penapis.samarkan(teks), 'hubungi ⟨surel disamarkan⟩');
    });

    test('beberapa alamat surel disamarkan seluruhnya', () {
      final String hasil = penapis.samarkan(
        'a@x.id dan b@y.ac.id, bukan c@z.org',
      );

      expect(hasil, isNot(contains('@')));
      expect('⟨surel disamarkan⟩'.allMatches(hasil).length, 3);
    });

    test('samarkan tidak mengubah teks tanpa surel', () {
      const String teks = 'tidak ada alamat di sini';
      expect(penapis.samarkan(teks), teks);
    });

    test('penapisan mendahului penyamaran, bukan menggantikannya', () {
      // Kunci API tetap ditolak meskipun teksnya juga memuat surel. Bila
      // urutannya dibalik, penyamaran akan menyembunyikan bukti penolakan.
      final HasilPenapisan hasil = penapis.periksa(
        'email saya a@b.id, kunci sk-abcdefghijklmnop',
      );

      expect(hasil.diizinkan, isFalse);
      expect(hasil.alasan, contains('kunci API'));
    });

    test('toString HasilPenapisan memuat putusan dan alasan', () {
      expect(
        const HasilPenapisan(diizinkan: true).toString(),
        'HasilPenapisan(diizinkan: true)',
      );
      expect(
        const HasilPenapisan(diizinkan: false, alasan: 'x').toString(),
        'HasilPenapisan(diizinkan: false, x)',
      );
    });
  });

  // =========================================================================
  // Bagian 5 — LayananAiLokal
  // =========================================================================
  group('Bagian 5 — LayananAiLokal', () {
    test('menyatakan dirinya berjalan di perangkat', () {
      expect(LayananAiLokal().nama, 'Lokal (di perangkat)');
    });

    test('memenuhi kontrak LayananAi', () {
      expect(LayananAiLokal(), isA<LayananAi>());
    });

    test('jawaban datang sebagai banyak potongan, bukan satu blok', () async {
      final LayananAiLokal layanan = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
      );
      final List<String> potongan = await layanan.kirim('dispose').toList();

      expect(
        potongan.length,
        greaterThan(5),
        reason: 'Aliran harus bertahap supaya efek mengetik dapat diamati.',
      );
    });

    test('potongan yang disambungkan sama dengan jawaban utuhnya', () async {
      final LayananAiLokal layanan = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
      );
      final StringBuffer buffer = StringBuffer();
      await for (final String p in layanan.kirim('dispose')) {
        buffer.write(p);
      }

      expect(buffer.toString(), LayananAiLokal.jawabanUntuk('dispose'));
    });

    test('potongJawaban mempertahankan spasi saat disambungkan kembali', () {
      const String teks = 'satu dua tiga empat';
      expect(LayananAiLokal.potongJawaban(teks).join(), teks);
    });

    test(
      'potongJawaban pada teks kosong menghasilkan satu potongan kosong',
      () {
        expect(LayananAiLokal.potongJawaban(''), <String>['']);
      },
    );

    test(
      'potongJawaban hanya memberi spasi pada potongan yang bukan terakhir',
      () {
        final List<String> hasil = LayananAiLokal.potongJawaban('a b c');

        expect(hasil, <String>['a ', 'b ', 'c']);
      },
    );

    test('jawabanUntuk bersifat murni: masukan sama, jawaban sama', () {
      expect(
        LayananAiLokal.jawabanUntuk('jelaskan state'),
        LayananAiLokal.jawabanUntuk('jelaskan state'),
      );
    });

    test('jawabanUntuk mengenali kata kunci', () {
      expect(LayananAiLokal.jawabanUntuk('dispose'), contains('dispose()'));
      expect(LayananAiLokal.jawabanUntuk('apa itu state'), contains('State'));
      expect(LayananAiLokal.jawabanUntuk('async'), contains('await'));
      expect(LayananAiLokal.jawabanUntuk('soal kuota'), contains('jendela'));
      expect(LayananAiLokal.jawabanUntuk('privasi'), contains('disamarkan'));
    });

    test('jawabanUntuk tidak peka huruf besar-kecil', () {
      expect(
        LayananAiLokal.jawabanUntuk('DISPOSE'),
        LayananAiLokal.jawabanUntuk('dispose'),
      );
    });

    test('jawabanUntuk meminta pertanyaan bila masukan kosong', () {
      expect(LayananAiLokal.jawabanUntuk('   '), contains('Tuliskan'));
    });

    test('jawabanUntuk mengarahkan bila kata kunci tidak dikenali', () {
      final String jawaban = LayananAiLokal.jawabanUntuk('pertanyaan asing');

      expect(jawaban, contains('Belum ada jawaban'));
      expect(jawaban, contains('kuota'));
    });

    test(
      'permintaan yang melewati batas kuota ditolak dengan sebab batasKuota',
      () async {
        final PenjagaKuota kuota = PenjagaKuota(
          batas: 2,
          jendela: const Duration(minutes: 1),
        );
        final LayananAiLokal layanan = LayananAiLokal(
          penjaga: kuota,
          jedaPerPotongan: Duration.zero,
        );

        await layanan.kirim('state').toList();
        await layanan.kirim('state').toList();

        await expectLater(
          layanan.kirim('state').toList(),
          throwsA(
            isA<GalatAi>().having(
              (GalatAi e) => e.sebab,
              'sebab',
              SebabGalat.batasKuota,
            ),
          ),
        );
      },
    );

    test('permintaan yang ditolak tidak menambah pemakaian kuota', () async {
      final PenjagaKuota kuota = PenjagaKuota(
        batas: 1,
        jendela: const Duration(minutes: 1),
      );
      final LayananAiLokal layanan = LayananAiLokal(
        penjaga: kuota,
        jedaPerPotongan: Duration.zero,
      );

      await layanan.kirim('state').toList();
      expect(kuota.sisa, 0);

      await expectLater(
        layanan.kirim('state').toList(),
        throwsA(isA<GalatAi>()),
      );
      expect(kuota.sisa, 0, reason: 'Penolakan tidak boleh menambah catatan.');
    });

    test('kuota bawaan adalah lima permintaan per menit', () async {
      final LayananAiLokal layanan = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
      );

      for (int i = 0; i < 5; i++) {
        await layanan.kirim('state').toList();
      }

      await expectLater(
        layanan.kirim('state').toList(),
        throwsA(isA<GalatAi>()),
      );
    });

    test(
      'simulasiGagal benar-benar gagal, bukan sekadar terlihat gagal',
      () async {
        final LayananAiLokal layanan = LayananAiLokal(
          jedaPerPotongan: Duration.zero,
          simulasiGagal: true,
        );

        await expectLater(
          layanan.kirim('state').toList(),
          throwsA(
            isA<GalatAi>()
                .having((GalatAi e) => e.sebab, 'sebab', SebabGalat.jaringan)
                .having(
                  (GalatAi e) => e.detail,
                  'detail',
                  'simulasi praktikum',
                ),
          ),
        );
      },
    );

    test('kegagalan jaringan layak diulang', () async {
      final LayananAiLokal layanan = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
        simulasiGagal: true,
      );

      try {
        await layanan.kirim('state').toList();
        fail('Seharusnya melempar GalatAi.');
      } on GalatAi catch (e) {
        expect(e.layakDiulang, isTrue);
      }
    });

    test('tutup dapat dipanggil tanpa melempar', () {
      expect(LayananAiLokal().tutup, returnsNormally);
    });

    test('jeda antar potongan benar-benar menunda aliran', () async {
      final LayananAiLokal layanan = LayananAiLokal(
        jedaPerPotongan: const Duration(milliseconds: 20),
      );
      final Stopwatch jam = Stopwatch()..start();

      await layanan.kirim('async').toList();

      jam.stop();
      expect(jam.elapsedMilliseconds, greaterThanOrEqualTo(20));
    });
  });

  // =========================================================================
  // Bagian 6 — LayananAiRingkas
  // =========================================================================
  group('Bagian 6 — LayananAiRingkas', () {
    test('nama menyebut bahwa jawaban diringkas', () {
      final LayananAiRingkas ringkas = LayananAiRingkas(LayananAiLokal());
      expect(ringkas.nama, 'Lokal (di perangkat) · ringkas');
    });

    test('tetap memenuhi kontrak LayananAi', () {
      expect(LayananAiRingkas(LayananAiLokal()), isA<LayananAi>());
    });

    test('jawaban lebih pendek daripada sumbernya', () async {
      final LayananAiLokal dasar = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
      );
      final LayananAiRingkas ringkas = LayananAiRingkas(dasar, maksKata: 5);

      final String utuh = (await dasar.kirim('dispose').toList()).join();
      final String singkat = (await ringkas.kirim('dispose').toList()).join();

      expect(singkat.length, lessThan(utuh.length));
      expect(utuh, startsWith(singkat));
    });

    test(
      'hasilnya satu potongan, karena potongan ditahan lebih dahulu',
      () async {
        final LayananAiRingkas ringkas = LayananAiRingkas(
          LayananAiLokal(jedaPerPotongan: Duration.zero),
        );

        final List<String> potongan = await ringkas.kirim('dispose').toList();

        expect(potongan, hasLength(1));
      },
    );

    test('maksKata menentukan jumlah potongan yang diambil', () async {
      final LayananAiLokal dasar = LayananAiLokal(
        jedaPerPotongan: Duration.zero,
      );
      final LayananAiRingkas ringkas = LayananAiRingkas(dasar, maksKata: 3);

      final String hasil = (await ringkas.kirim('dispose').toList()).join();
      final List<String> semua = LayananAiLokal.potongJawaban(
        LayananAiLokal.jawabanUntuk('dispose'),
      );

      expect(hasil, semua.take(3).join());
    });

    test('jawaban yang lebih pendek dari maksKata tidak terpotong', () async {
      final LayananAiRingkas ringkas = LayananAiRingkas(
        LayananAiLokal(jedaPerPotongan: Duration.zero),
        maksKata: 100,
      );

      final String hasil = (await ringkas.kirim('dispose').toList()).join();

      expect(hasil, LayananAiLokal.jawabanUntuk('dispose'));
    });

    test('tutup diteruskan ke layanan sumber', () {
      final LayananPalsu palsu = LayananPalsu();
      LayananAiRingkas(palsu).tutup();

      expect(palsu.jumlahTutup, 1);
    });

    test('kegagalan sumber diteruskan tanpa ditelan', () async {
      final LayananPalsu palsu = LayananPalsu(
        galat: const GalatAi(SebabGalat.batasKuota),
      );
      final LayananAiRingkas ringkas = LayananAiRingkas(palsu);

      await expectLater(
        ringkas.kirim('apa saja').toList(),
        throwsA(
          isA<GalatAi>().having(
            (GalatAi e) => e.sebab,
            'sebab',
            SebabGalat.batasKuota,
          ),
        ),
      );
    });

    test('dekorator dapat dibungkus lagi tanpa mengubah kontrak', () async {
      final LayananAi dua = LayananAiRingkas(
        LayananAiRingkas(
          LayananAiLokal(jedaPerPotongan: Duration.zero),
          maksKata: 8,
        ),
        maksKata: 2,
      );

      expect(dua.nama, contains('ringkas · ringkas'));
      final String hasil = (await dua.kirim('dispose').toList()).join();
      expect(hasil, isNotEmpty);
    });
  });

  // =========================================================================
  // Bagian 7 — ViewModelObrolan
  // =========================================================================
  group('Bagian 7 — ViewModelObrolan', () {
    late ViewModelObrolan model;

    ViewModelObrolan buatModel({
      List<String> potongan = const <String>['ha', 'lo'],
      GalatAi? galat,
      bool menggantung = false,
      LayananAi? layanan,
    }) {
      final ViewModelObrolan m = ViewModelObrolan(
        layanan:
            layanan ??
            LayananPalsu(
              potongan: potongan,
              galat: galat,
              menggantung: menggantung,
            ),
      );
      // Dibuang lewat addTearDown, bukan lewat satu tearDown bersama.
      // Alasannya penting: satu `tearDown` tingkat grup akan membuang model
      // milik uji sebelumnya, dan membuang dua kali pada objek yang sama
      // melempar kesalahan di dalam ChangeNotifier.
      addTearDown(m.dispose);
      return m;
    }

    test('keadaan awal kosong', () {
      model = buatModel();

      expect(model.status, isA<ObrolanKosong>());
      expect(model.pesan, isEmpty);
      expect(model.sedangSibuk, isFalse);
    });

    test('nama penyedia diteruskan dari layanan', () {
      model = buatModel(layanan: LayananAiLokal());
      expect(model.namaPenyedia, 'Lokal (di perangkat)');
    });

    test('kirim menambahkan pesan pengguna dan balon asisten', () async {
      model = buatModel();
      await model.kirim('halo');

      expect(model.pesan, hasLength(2));
      expect(model.pesan.first.peran, PeranPesan.pengguna);
      expect(model.pesan.first.isi, 'halo');
      expect(model.pesan.last.peran, PeranPesan.asisten);
    });

    test('kirim menggabungkan seluruh potongan menjadi satu jawaban', () async {
      model = buatModel(potongan: <String>['satu ', 'dua ', 'tiga']);
      await model.kirim('halo');

      expect(model.pesan.last.isi, 'satu dua tiga');
    });

    test('kirim berakhir pada keadaan siap', () async {
      model = buatModel();
      await model.kirim('halo');

      expect(model.status, isA<ObrolanSiap>());
      expect(model.sedangSibuk, isFalse);
    });

    test('urutan keadaan: menunggu, mengalir, lalu siap', () async {
      model = buatModel(potongan: <String>['a', 'b', 'c']);
      final List<Type> transisi = <Type>[];
      model.addListener(() => transisi.add(model.status.runtimeType));

      await model.kirim('halo');

      expect(transisi.first, ObrolanMenunggu);
      expect(transisi.last, ObrolanSiap);
      expect(transisi, contains(ObrolanMengalir));
      expect(
        transisi.indexOf(ObrolanMengalir),
        greaterThan(transisi.indexOf(ObrolanMenunggu)),
      );
    });

    test('sedangSibuk benar selama permintaan berjalan', () async {
      model = buatModel(potongan: <String>['a', 'b', 'c']);
      final Future<void> jalan = model.kirim('halo');

      expect(model.sedangSibuk, isTrue);
      expect(model.status, isA<ObrolanMenunggu>());

      await jalan;
      expect(model.sedangSibuk, isFalse);
    });

    test('keadaan mengalir membawa pesan asisten yang sedang tumbuh', () async {
      model = buatModel(potongan: <String>['a ', 'b']);
      final List<String> mengalir = <String>[];
      model.addListener(() {
        final StatusObrolan s = model.status;
        if (s is ObrolanMengalir) mengalir.add(s.pesan.isi);
      });

      await model.kirim('halo');

      expect(mengalir, <String>['a ', 'a b']);
    });

    test('teks kosong tidak dikirim dan tidak menambah pesan', () async {
      model = buatModel();
      await model.kirim('   ');

      expect(model.pesan, isEmpty);
      expect(model.status, isA<ObrolanKosong>());
    });

    test('teks dipangkas sebelum dikirim', () async {
      final LayananPalsu palsu = LayananPalsu();
      model = buatModel(layanan: palsu);
      await model.kirim('  halo  ');

      expect(palsu.perintahTerakhir, 'halo');
      expect(model.pesan.first.isi, 'halo');
    });

    test('kirim kedua diabaikan selama permintaan pertama berjalan', () async {
      model = buatModel(potongan: <String>['a', 'b', 'c']);
      final Future<void> jalan = model.kirim('pertama');
      await model.kirim('kedua');

      await jalan;

      expect(model.pesan.where((PesanAi p) => p.dariPengguna), hasLength(1));
      expect(model.pesan.first.isi, 'pertama');
    });

    test('teks yang ditolak penapis tidak pernah dikirim ke layanan', () async {
      final LayananPalsu palsu = LayananPalsu();
      model = buatModel(layanan: palsu);

      await model.kirim('kunci saya sk-abcdefghijklmnop');

      expect(palsu.jumlahKirim, 0);
      expect(model.pesan, isEmpty);
    });

    test(
      'teks yang ditolak menghasilkan keadaan gagal yang dapat dijelaskan',
      () async {
        model = buatModel();
        await model.kirim('kunci saya sk-abcdefghijklmnop');

        final StatusObrolan status = model.status;
        expect(status, isA<ObrolanGagal>());
        expect(
          (status as ObrolanGagal).galat.sebab,
          SebabGalat.ditolakKeamanan,
        );
        expect(status.galat.layakDiulang, isFalse);
      },
    );

    test('alamat surel disamarkan sebelum disimpan dan dikirim', () async {
      final LayananPalsu palsu = LayananPalsu();
      model = buatModel(layanan: palsu);

      await model.kirim('hubungi budi@kampus.ac.id');

      expect(palsu.perintahTerakhir, isNot(contains('@')));
      expect(model.pesan.first.isi, isNot(contains('budi@kampus.ac.id')));
    });

    test(
      'kegagalan jaringan menghasilkan keadaan gagal yang layak diulang',
      () async {
        model = buatModel(galat: const GalatAi(SebabGalat.jaringan));
        await model.kirim('halo');

        final StatusObrolan status = model.status;
        expect(status, isA<ObrolanGagal>());
        expect((status as ObrolanGagal).galat.layakDiulang, isTrue);
      },
    );

    test('balon asisten yang masih kosong dibuang saat gagal', () async {
      model = buatModel(galat: const GalatAi(SebabGalat.jaringan));
      await model.kirim('halo');

      expect(
        model.pesan,
        hasLength(1),
        reason: 'Balon kosong yang tidak pernah terisi hanya membingungkan.',
      );
      expect(model.pesan.single.dariPengguna, isTrue);
    });

    test(
      'balon asisten yang sudah terisi sebagian dipertahankan saat gagal',
      () async {
        // Potongan pertama keluar, lalu aliran gagal. Pengguna berhak melihat
        // sejauh mana jawaban sempat datang.
        model = buatModel(
          layanan: _LayananGagalSetelah(<String>['satu ', 'dua']),
        );
        await model.kirim('halo');

        expect(model.pesan, hasLength(2));
        expect(model.pesan.last.isi, 'satu dua');
        expect(model.status, isA<ObrolanGagal>());
      },
    );

    test(
      'galat yang bukan GalatAi tidak membocorkan jenisnya ke pengguna',
      () async {
        model = buatModel(layanan: _LayananMelemparStateError());
        await model.kirim('halo');

        final StatusObrolan status = model.status;
        expect(status, isA<ObrolanGagal>());
        expect((status as ObrolanGagal).galat.sebab, SebabGalat.tidakDiketahui);
      },
    );

    test(
      'batal menghentikan permintaan dan mengembalikan keadaan siap',
      () async {
        model = buatModel(potongan: <String>['a', 'b', 'c'], menggantung: true);
        final Future<void> jalan = model.kirim('halo');

        await model.batal();

        expect(model.sedangSibuk, isFalse);
        expect(model.status, isA<ObrolanSiap>());
        await jalan;
      },
    );

    test('batal saat tidak ada permintaan tidak melempar', () async {
      model = buatModel();
      await expectLater(model.batal(), completes);
    });

    test('akuiGalat menutup pesan gagal tanpa menghapus riwayat', () async {
      model = buatModel(galat: const GalatAi(SebabGalat.kunciTidakSah));
      await model.kirim('halo');
      final int jumlahPesan = model.pesan.length;

      model.akuiGalat();

      expect(model.status, isA<ObrolanSiap>());
      expect(model.pesan, hasLength(jumlahPesan));
    });

    test('akuiGalat tidak berpengaruh bila tidak sedang gagal', () async {
      model = buatModel();
      await model.kirim('halo');
      final StatusObrolan sebelum = model.status;

      model.akuiGalat();

      expect(model.status, sebelum);
    });

    test(
      'ulangi membuang ekor yang gagal lalu mengirim ulang pesan terakhir',
      () async {
        final _LayananGagalSekali layanan = _LayananGagalSekali();
        model = buatModel(layanan: layanan);

        await model.kirim('halo');
        expect(model.status, isA<ObrolanGagal>());

        await model.ulangi();

        expect(model.status, isA<ObrolanSiap>());
        expect(model.pesan.where((PesanAi p) => p.dariPengguna), hasLength(1));
        expect(model.pesan.last.isi, 'berhasil');
      },
    );

    test('ulangi tanpa pesan pengguna tidak melakukan apa pun', () async {
      model = buatModel();
      await expectLater(model.ulangi(), completes);
      expect(model.pesan, isEmpty);
    });

    test('ulangi tidak berjalan saat masih sibuk', () async {
      final LayananPalsu palsu = LayananPalsu(potongan: <String>['a']);
      model = buatModel(layanan: palsu);
      final Future<void> jalan = model.kirim('halo');

      await model.ulangi();

      expect(palsu.jumlahKirim, 1);
      await jalan;
    });

    test('bersihkan mengembalikan percakapan ke keadaan awal', () async {
      model = buatModel();
      await model.kirim('halo');

      model.bersihkan();

      expect(model.pesan, isEmpty);
      expect(model.status, isA<ObrolanKosong>());
    });

    test('daftar pesan yang dibaca pemanggil tidak dapat diubah', () async {
      model = buatModel();
      await model.kirim('halo');

      expect(
        () => model.pesan.add(
          const PesanAi(peran: PeranPesan.pengguna, isi: 'sisipan'),
        ),
        throwsUnsupportedError,
      );
    });

    test('dispose menutup layanan', () {
      final LayananPalsu palsu = LayananPalsu();
      final ViewModelObrolan m = ViewModelObrolan(layanan: palsu);

      m.dispose();

      expect(palsu.jumlahTutup, 1);
    });

    test('dispose setelah percakapan selesai tidak melempar', () async {
      final LayananPalsu palsu = LayananPalsu();
      final ViewModelObrolan m = ViewModelObrolan(layanan: palsu);
      await m.kirim('halo');

      expect(m.dispose, returnsNormally);
      expect(palsu.jumlahTutup, 1);
    });

    test('dispose di tengah permintaan tidak menggantungkan penunggu', () async {
      final ViewModelObrolan m = ViewModelObrolan(
        layanan: LayananPalsu(potongan: <String>['a'], menggantung: true),
      );
      final Future<void> jalan = m.kirim('halo');

      m.dispose();

      // Inilah uji yang paling mudah terlewat. Tanpa penyelesaian penunggu di
      // dalam dispose(), baris berikutnya tidak akan pernah selesai dan ujinya
      // menggantung sampai batas waktu.
      await expectLater(jalan, completes);
    });
  });

  // =========================================================================
  // Bagian 8 — Widget murni tampilan
  // =========================================================================
  group('Bagian 8 — Widget murni tampilan', () {
    Widget bungkus(Widget anak) => MaterialApp(home: Scaffold(body: anak));

    /// Mencari widget [Align] yang membungkus sebuah teks.
    ///
    /// Sengaja memakai pencari leluhur, bukan `find.byType(Align).first`:
    /// pohon widget Flutter memuat banyak `Align`, sehingga urutan kemunculan
    /// bukan bukti yang sahih.
    Align alignDari(WidgetTester tester, String teks) {
      return tester.widget<Align>(
        find.ancestor(of: find.text(teks), matching: find.byType(Align)).first,
      );
    }

    testWidgets('GelembungPesan menampilkan isi pesan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        bungkus(
          const GelembungPesan(
            pesan: PesanAi(peran: PeranPesan.asisten, isi: 'jawaban lengkap'),
          ),
        ),
      );

      expect(find.text('jawaban lengkap'), findsOneWidget);
    });

    testWidgets('GelembungPesan menampilkan penanda saat isi masih kosong', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        bungkus(
          const GelembungPesan(
            pesan: PesanAi(peran: PeranPesan.asisten, isi: ''),
          ),
        ),
      );

      expect(find.text('…'), findsOneWidget);
    });

    testWidgets('GelembungPesan menjajar pesan pengguna ke kanan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        bungkus(
          const GelembungPesan(
            pesan: PesanAi(peran: PeranPesan.pengguna, isi: 'tanya'),
          ),
        ),
      );

      expect(alignDari(tester, 'tanya').alignment, Alignment.centerRight);
    });

    testWidgets('GelembungPesan menjajar jawaban asisten ke kiri', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        bungkus(
          const GelembungPesan(
            pesan: PesanAi(peran: PeranPesan.asisten, isi: 'jawab'),
          ),
        ),
      );

      expect(alignDari(tester, 'jawab').alignment, Alignment.centerLeft);
    });

    testWidgets('BilahKuota menampilkan sisa dan batas', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(bungkus(const BilahKuota(sisa: 3, batas: 5)));

      expect(find.text('Sisa kuota: 3/5'), findsOneWidget);
    });

    testWidgets('BilahKuota meneruskan rasio ke indikator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(bungkus(const BilahKuota(sisa: 1, batas: 4)));

      final LinearProgressIndicator bar = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      expect(bar.value, closeTo(0.25, 0.0001));
    });

    testWidgets('BilahKuota dengan batas nol tidak membagi dengan nol', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(bungkus(const BilahKuota(sisa: 0, batas: 0)));

      final LinearProgressIndicator bar = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      expect(bar.value, 0.0);
    });

    testWidgets('KartuPengungkapan selalu menyatakan bahwa jawaban dibuat AI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(bungkus(const KartuPengungkapan()));

      expect(find.textContaining('dihasilkan oleh model AI'), findsOneWidget);
      expect(
        find.textContaining('Jangan kirimkan data pribadi'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  // =========================================================================
  // Bagian 9 — LayarObrolanAi
  // =========================================================================
  group('Bagian 9 — LayarObrolanAi', () {
    // Permukaan bawaan 800x600 terlalu pendek untuk layar ini: kartu
    // pengungkapan, bilah kuota, baris penyedia, daftar, dan bilah masukan
    // akan berdesakan. Permukaan tinggi membuat seluruh bagian benar-benar
    // dibangun, sehingga uji ini menguji tata letaknya dan bukan kebetulan
    // pemotongan layar.
    Future<void> siapkan(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const Modul10App());
      await tester.pump();
    }

    testWidgets('aplikasi modul memakai Material 3 dan judul modul', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Modul10App());
      await tester.pump();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.title, 'Modul 10 — AI Feature Integration');
      expect(app.theme?.useMaterial3, isTrue);
      expect(find.byType(LayarObrolanAi), findsOneWidget);
    });

    testWidgets('layar awal menampilkan ajakan memulai percakapan', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      expect(find.textContaining('Belum ada percakapan'), findsOneWidget);
    });

    testWidgets('pengungkapan, bilah kuota, dan nama penyedia selalu tampil', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      expect(find.byType(KartuPengungkapan), findsOneWidget);
      expect(find.byType(BilahKuota), findsOneWidget);
      expect(find.text('Sisa kuota: 5/5'), findsOneWidget);
      expect(find.text('Penyedia: Lokal (di perangkat)'), findsOneWidget);
    });

    testWidgets('mengetik lalu menekan kirim menampilkan pertanyaan pengguna', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'jelaskan dispose');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text('jelaskan dispose'), findsOneWidget);

      // Aliran jawaban memakai Future.delayed. Setiap uji layar harus
      // menghabiskan sisa timer sebelum berakhir; kalau tidak, flutter_test
      // melaporkan "A Timer is still pending".
      await pompaHinggaTenang(tester);
    });

    testWidgets(
      'selama jawaban mengalir, tombol kirim berganti jadi hentikan',
      (WidgetTester tester) async {
        await siapkan(tester);

        await tester.enterText(find.byType(TextField), 'jelaskan dispose');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        expect(find.byIcon(Icons.stop), findsOneWidget);
        expect(find.byIcon(Icons.send), findsNothing);

        await pompaHinggaTenang(tester);
      },
    );

    testWidgets('jawaban lengkap muncul setelah aliran selesai', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'jelaskan dispose');
      await tester.tap(find.byIcon(Icons.send));
      await pompaHinggaTenang(tester);

      expect(find.text(LayananAiLokal.jawabanUntuk('dispose')), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
    });

    testWidgets('kuota berkurang setelah satu permintaan terkirim', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);
      expect(find.text('Sisa kuota: 5/5'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'state');
      await tester.tap(find.byIcon(Icons.send));
      await pompaHinggaTenang(tester);

      expect(find.text('Sisa kuota: 4/5'), findsOneWidget);
    });

    testWidgets('menekan hentikan mengembalikan tombol kirim', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'jelaskan dispose');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.byIcon(Icons.stop));
      // `batal()` bekerja lewat beberapa mikrotask, dan timer aliran yang
      // belum sempat berbunyi masih tertinggal. Satu pompa pendek tidak cukup
      // untuk keduanya.
      await pompaHinggaTenang(tester);

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
    });

    testWidgets('tombol kosongkan menghapus seluruh percakapan', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'state');
      await tester.tap(find.byIcon(Icons.send));
      await pompaHinggaTenang(tester);
      expect(find.text('state'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text('state'), findsNothing);
      expect(find.textContaining('Belum ada percakapan'), findsOneWidget);
    });

    testWidgets('sakelar Ringkas menukar penyedia', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(
        find.text('Penyedia: Lokal (di perangkat) · ringkas'),
        findsOneWidget,
      );
    });

    testWidgets('penukaran penyedia saat jawaban mengalir tidak melempar', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'jelaskan dispose');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 80));

      await tester.tap(find.byType(Switch));
      await pompaHinggaTenang(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('penolakan penapis muncul sebagai pesan kesalahan di layar', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(
        find.byType(TextField),
        'kunci saya sk-abcdefghijklmnop',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.textContaining('penyaring keamanan'), findsOneWidget);
      // Kegagalan ini tidak layak diulang: tombolnya harus "Tutup".
      expect(find.text('Tutup'), findsOneWidget);
      expect(find.text('Coba lagi'), findsNothing);
    });

    testWidgets('pesan kesalahan dapat ditutup tanpa menghapus pertanyaan', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(
        find.byType(TextField),
        'kunci saya sk-abcdefghijklmnop',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      await tester.tap(find.text('Tutup'));
      await tester.pump();

      expect(find.textContaining('penyaring keamanan'), findsNothing);
    });

    testWidgets('layar dapat ditutup di tengah jawaban tanpa kesalahan', (
      WidgetTester tester,
    ) async {
      await siapkan(tester);

      await tester.enterText(find.byType(TextField), 'jelaskan dispose');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 80));

      // Mengganti seluruh pohon widget memicu dispose pada layar.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  // Bagian 10 — Aturan dependensi
  // =========================================================================
  group('Bagian 10 — Aturan dependensi', () {
    // Dua berkas dikecualikan dari pemeriksaan kredensial, dan keduanya
    // disebut terbuka di sini:
    //
    //   - penapis_aman.dart memuat POLA kunci API. Ia memang menyebut
    //     bentuknya supaya dapat menolaknya, dan tidak memuat kunci sungguhan.
    //   - demo_obrolan.dart memuat satu kunci palsu sebagai DATA UJI, sama
    //     seperti contoh_kode_ai.dart pada Modul 09. Tanpa contoh itu, demo
    //     tidak dapat membuktikan bahwa penapisnya bekerja.
    //
    // Pengecualian yang terlihat masih dapat diperiksa orang lain.
    const List<String> dikecualikanDariKredensial = <String>[
      'penapis_aman.dart',
      'demo_obrolan.dart',
    ];

    late List<File> berkas;

    setUpAll(() {
      berkas = berkasDart('lib/modul_10');
    });

    test('folder modul berisi seluruh lapisan yang diharapkan', () {
      final Set<String> folder =
          berkas
              .map((File f) => f.path.replaceAll(r'\', '/').split('/')[2])
              .toSet();

      expect(
        folder,
        containsAll(<String>[
          'domain',
          'data',
          'presentation',
          'widgets',
          'screens',
        ]),
      );
      expect(berkas.length, greaterThanOrEqualTo(15));
    });

    test('lapisan domain tidak bergantung pada apa pun di luar dirinya', () {
      // Inilah inti modul ini. Model, galat, pembatas kuota, dan penapis harus
      // dapat diuji tanpa Flutter dan tanpa jaringan — dan satu impor ke
      // `package:flutter` sudah cukup untuk membatalkan sifat itu.
      for (final File f in berkas) {
        if (!f.path.contains('/domain/')) continue;
        for (final String i in imporDari(f)) {
          expect(
            i.startsWith('package:flutter'),
            isFalse,
            reason:
                '${f.path} mengimpor $i. Lapisan domain harus bebas Flutter.',
          );
          expect(
            i.startsWith('dart:io'),
            isFalse,
            reason:
                '${f.path} mengimpor $i. Lapisan domain harus bebas berkas.',
          );
          for (final String terlarang in <String>[
            '../data/',
            '../presentation/',
            '../widgets/',
            '../screens/',
          ]) {
            expect(
              i.contains(terlarang),
              isFalse,
              reason: '${f.path} mengimpor $i. Arah ketergantungan terbalik.',
            );
          }
        }
      }
    });

    test('lapisan data hanya bergantung pada domain', () {
      for (final File f in berkas) {
        if (!f.path.contains('/data/')) continue;
        for (final String i in imporDari(f)) {
          final bool boleh =
              i.startsWith('../domain/') || i.startsWith('dart:');
          expect(
            boleh,
            isTrue,
            reason:
                '${f.path} mengimpor $i. Lapisan data hanya boleh '
                'mengimpor domain dan pustaka inti Dart.',
          );
        }
      }
    });

    test('lapisan presentation tidak mengenal penyedia konkret', () {
      // Bila aturan ini dilanggar, penukaran penyedia akan menyentuh pengatur
      // keadaan — dan seluruh alasan modul ini memakai kontrak akan hilang.
      for (final File f in berkas) {
        if (!f.path.contains('/presentation/')) continue;
        for (final String i in imporDari(f)) {
          expect(
            i.contains('../data/'),
            isFalse,
            reason:
                '${f.path} mengimpor $i. Pengatur keadaan tidak boleh '
                'menyentuh penyedia konkret.',
          );
          expect(
            i.startsWith('package:flutter/material.dart'),
            isFalse,
            reason: '${f.path} mengimpor $i. Cukup flutter/foundation.dart.',
          );
        }
      }
    });

    test('widget tidak mengenal pengatur keadaan maupun penyedia', () {
      for (final File f in berkas) {
        if (!f.path.contains('/widgets/')) continue;
        for (final String i in imporDari(f)) {
          for (final String terlarang in <String>[
            '../data/',
            '../presentation/',
            '../screens/',
          ]) {
            expect(
              i.contains(terlarang),
              isFalse,
              reason: '${f.path} mengimpor $i. Widget harus murni tampilan.',
            );
          }
        }
      }
    });

    test('penyedia konkret dirakit di tepat satu tempat di dalam aplikasi', () {
      // Perakitan terpusat belum dibutuhkan selama hanya satu layar yang
      // memakainya. Yang penting bukan jumlahnya, melainkan bahwa jumlah itu
      // diketahui dan dikunci — supaya penyebarannya tidak terjadi diam-diam.
      //
      // demo_obrolan.dart dikecualikan karena ia alat baris perintah, bukan
      // bagian dari aplikasi. Definisi kelasnya sendiri juga tentu dikecualikan.
      final List<String> perakit = <String>[];
      for (final File f in berkas) {
        if (f.path.replaceAll(r'\', '/').endsWith('layanan_ai_lokal.dart'))
          continue;
        if (f.path.replaceAll(r'\', '/').endsWith('demo_obrolan.dart'))
          continue;
        if (RegExp(r'LayananAiLokal\s*\(').hasMatch(tanpaKomentar(f))) {
          perakit.add(f.path.replaceAll(r'\', '/'));
        }
      }

      expect(perakit, <String>[
        'lib/modul_10/screens/layar_obrolan_ai.dart',
      ], reason: 'Penyedia konkret hanya boleh dirakit di dalam layar.');
    });

    test('tidak ada kredensial sungguhan di dalam kode aplikasi', () {
      // Aturan ini adalah pelajaran Modul 09 yang diterapkan pada modul ini
      // sendiri: kunci yang ditulis di kode akan berakhir di riwayat Git.
      final RegExp kunci = RegExp(
        r'(sk-[A-Za-z0-9]{12,}|AIza[0-9A-Za-z_\-]{20,}|ghp_[A-Za-z0-9]{20,})',
      );

      for (final File f in berkas) {
        if (dikecualikanDariKredensial.any((String n) => f.path.endsWith(n))) {
          continue;
        }
        expect(
          kunci.hasMatch(tanpaKomentar(f)),
          isFalse,
          reason: '${f.path} memuat sesuatu yang menyerupai kredensial.',
        );
      }
    });

    test('tidak ada print() di luar alat baris perintah', () {
      for (final File f in berkas) {
        if (f.path.endsWith('demo_obrolan.dart')) continue;
        expect(
          RegExp(r'(?<![\w.])print\s*\(').hasMatch(tanpaKomentar(f)),
          isFalse,
          reason:
              '${f.path} memakai print(). Pakai debugPrint() agar tidak '
              'ikut tercetak pada build rilis.',
        );
      }
    });

    test('berkas sumber tidak meninggalkan TODO atau FIXME', () {
      for (final File f in berkas) {
        final String isi = tanpaKomentar(f);
        expect(isi.contains('TODO'), isFalse, reason: '${f.path} memuat TODO.');
        expect(
          isi.contains('FIXME'),
          isFalse,
          reason: '${f.path} memuat FIXME.',
        );
      }
    });

    test('setiap berkas sumber memuat komentar dokumentasi', () {
      // Berkas tanpa dokumentasi akan menjadi teka-teki bagi mahasiswa yang
      // membukanya enam bulan kemudian — termasuk penulisnya sendiri.
      for (final File f in berkas) {
        if (f.path.endsWith('demo_obrolan.dart')) continue;
        expect(
          f.readAsStringSync().contains('///'),
          isTrue,
          reason: '${f.path} tidak memuat satu pun komentar dokumentasi (///).',
        );
      }
    });
  });
}

// ---------------------------------------------------------------------------
// Layanan bantu khusus uji
// ---------------------------------------------------------------------------

/// Layanan yang mengeluarkan beberapa potongan, lalu gagal di tengah aliran.
class _LayananGagalSetelah implements LayananAi {
  _LayananGagalSetelah(this.potongan);

  final List<String> potongan;

  @override
  String get nama => 'Gagal setelah beberapa potongan';

  @override
  Stream<String> kirim(String perintah) async* {
    for (final String p in potongan) {
      yield p;
    }
    throw const GalatAi(SebabGalat.jaringan);
  }

  @override
  void tutup() {}
}

/// Layanan yang gagal pada percobaan pertama dan berhasil pada percobaan kedua.
class _LayananGagalSekali implements LayananAi {
  int _percobaan = 0;

  @override
  String get nama => 'Gagal sekali';

  @override
  Stream<String> kirim(String perintah) async* {
    _percobaan++;
    if (_percobaan == 1) throw const GalatAi(SebabGalat.jaringan);
    yield 'berhasil';
  }

  @override
  void tutup() {}
}

/// Layanan yang melempar galat di luar [GalatAi].
///
/// Dipakai untuk membuktikan bahwa jenis galat asing tidak bocor ke layar.
class _LayananMelemparStateError implements LayananAi {
  @override
  String get nama => 'Melempar StateError';

  @override
  Stream<String> kirim(String perintah) async* {
    throw StateError('galat yang tidak dikenali modul ini');
  }

  @override
  void tutup() {}
}
