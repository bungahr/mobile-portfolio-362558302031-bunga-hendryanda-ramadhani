# Proyek dosen Modul 10-API: 9router

Clone terpisah dari `modul_10_integrasi_ai`. Entry point default `lib/main.dart` membuka demo **simulator atau API 9router melalui proxy lokal**. Kontrak dan ViewModel tetap digunakan. API key hanya dikonfigurasi pada proxy Node.js, bukan pada aplikasi Flutter.

**Panduan utama: [PANDUAN-9ROUTER.md](PANDUAN-9ROUTER.md).** Isi konfigurasi proxy, jalankan proxy, lalu jalankan Flutter pada port 7081. Belum ada API key atau panggilan provider nyata yang disiapkan otomatis.

Entry point salinan: `main_starter.dart` untuk simulator materi, `main_kunci.dart` untuk kunci, dan `main_ai.dart` untuk Ollama. Bagian berikut menjelaskan berkas warisan clone. Untuk 9router gunakan panduan utama di atas.

Obrolan AI lokal dengan kontrak `LayananAi` tiga anggota, jawaban bertahap lewat `Stream`, pembatas kuota, penapis kunci/kartu, dan penyamaran surel. Tanpa API key sungguhan.

## Demonstrasi dengan model AI nyata

Tersedia entry point terpisah `lib/main_ai.dart` dengan pilihan simulator atau Ollama. Versi materi dan kunci latihan tetap dipertahankan. Baca [PANDUAN-MODEL-NYATA.md](PANDUAN-MODEL-NYATA.md) sebelum menjalankan. Mode Ollama memerlukan server model yang aktif; simulator tidak memerlukannya.

Kode di `lib/modul_10/` adalah salinan starter `classroom-template` dan identik dengan kode yang ditampilkan di halaman modul. Jawaban latihan sengaja dipisah ke folder kunci supaya demo starter tidak berubah.

## Menjalankan

Sekali saja setelah menyalin folder ini (folder platform tidak disertakan):

```bash
flutter create --platforms=web,android .
flutter pub get
```

Lalu:

```bash
flutter run -d chrome
flutter run -d chrome -t lib/main_kunci.dart   # versi kunci: 3 penyedia + sisa waktu kuota
dart run lib/modul_10/demo_obrolan.dart
flutter analyze
flutter test
```

Pada macOS Ventura gunakan SDK yang dipin, misalnya `nix-shell ../shell.nix`.

## Struktur

```text
lib/modul_10/          ← salinan starter (sama dengan kode di halaman modul)
lib/kunci_latihan/      ← jawaban Latihan Mandiri (tidak dibagikan)
test/modul_10_test.dart ← test starter
test/kunci_*_test.dart  ← test kunci
```

## Poin demo di kelas

1. Kirim pertanyaan dan tunjukkan gelembung tumbuh per potongan. Ubah `jedaPerPotongan` menjadi 400 ms agar bertahapnya terlihat di proyektor.
2. Kirim enam pertanyaan dalam satu menit → pita kuota habis. Pada versi kunci, pesannya berbunyi "Coba lagi dalam N detik."
3. Tempel `sk-abcdefghijklmnop` → ditolak dan kuota **tidak** berkurang. Tempel alamat surel → disamarkan, bukan ditolak.
4. Versi kunci: pilih **Terbatas** dan tunjukkan bahwa `view_model_obrolan.dart` tidak berubah sama sekali (bandingkan dengan `diff`).

## Panduan penilaian praktikum

| Aspek | Indikator lulus |
|---|---|
| Kontrak | Menjelaskan mengapa kontrak hanya tiga anggota. |
| Keadaan | Menyebut kelima keadaan percakapan dan transisinya. |
| Keamanan | Membedakan menolak (kunci/kartu) dan menyamarkan (surel), beserta alasannya. |
| Bukti | Tiga keluaran perintah verifikasi disimpan. |

Kunci Latihan Mandiri dan kunci kuis ada di [`KUNCI-LATIHAN.md`](KUNCI-LATIHAN.md).
