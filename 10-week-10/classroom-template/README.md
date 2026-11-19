# Modul 10 — Integrasi AI pada Flutter

**Nama:** Bunga Hendryanda Ramadhani  
**Program Studi:** D4 Teknologi Rekayasa Perangkat Lunak  
**Kelas:** 2C TRPL  
**Mata Kuliah:** Pemrograman Perangkat Bergerak

## 1. Deskripsi Proyek

Proyek ini merupakan hasil praktikum Modul 10 yang membahas integrasi Artificial Intelligence (AI) pada aplikasi Flutter.

Pada praktikum ini, saya mempelajari cara menghubungkan aplikasi dengan layanan AI, mengelola pesan, menerapkan pembatasan penggunaan, melakukan penyaringan data sensitif, serta menampilkan respons AI secara streaming.

Aplikasi dikembangkan menggunakan Flutter dan Dart dengan pendekatan pemisahan antara data, domain, presentation, dan widgets.

## 2. Fitur yang Dikembangkan

Beberapa fitur yang terdapat pada aplikasi:

1. **Chat AI** — pengguna dapat mengirim pesan dan menerima respons dari layanan AI.
2. **Streaming Respons** — respons ditampilkan secara bertahap sehingga pengguna tidak perlu menunggu seluruh jawaban selesai.
3. **Pembatasan Kuota** — aplikasi membatasi jumlah permintaan agar penggunaan layanan lebih terkontrol.
4. **Penyaringan API Key** — kredensial tidak ditampilkan secara langsung dalam pesan atau keluaran aplikasi.
5. **Penyamaran Data Sensitif** — data pribadi seperti email dan informasi sensitif lainnya diperiksa sebelum diproses.
6. **Mode Ringkas** — aplikasi dapat menggunakan respons yang lebih singkat.
7. **Simulasi Kegagalan** — digunakan untuk menguji bagaimana aplikasi menangani kondisi ketika layanan AI mengalami kesalahan.

## 3. Struktur Folder

```text
classroom-template/
├── docs/
│   └── verification/
├── evidence/
│   ├── output/
│   └── screenshots/
├── lib/
│   ├── main.dart
│   ├── main_starter.dart
│   └── modul_10/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       ├── screens/
│       ├── widgets/
│       ├── demo_obrolan.dart
│       └── modul_10_app.dart
├── test/
│   ├── modul_10_test.dart
│   ├── modul_10_mahasiswa_test.dart
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

## 4. Cara Menjalankan Aplikasi

Pastikan Flutter sudah terpasang, kemudian buka terminal pada folder proyek.

Mengunduh dependensi:

```powershell
flutter pub get
```

Menjalankan aplikasi melalui Chrome:

```powershell
flutter run -d chrome
```

## 5. Pengujian Aplikasi

Pengujian dilakukan untuk memastikan aplikasi berjalan sesuai dengan fungsi yang telah dibuat.

**Flutter Analyze**

```powershell
flutter analyze
```

Hasil: `No issues found!`

**Pengujian resmi Modul 10**

```powershell
flutter test test/modul_10_test.dart
```

Hasil: seluruh 130 pengujian berhasil.

**Pengujian mahasiswa**

```powershell
flutter test test/modul_10_mahasiswa_test.dart
```

Hasil: seluruh 4 pengujian berhasil.

**Menjalankan demo obrolan**

```powershell
dart run lib/modul_10/demo_obrolan.dart
```

Demo digunakan untuk melihat proses streaming respons, pembatasan kuota, dan penyaringan data.

## 6. Hasil Pengujian

Berdasarkan pengujian yang telah dilakukan:

- Flutter Analyze berhasil tanpa masalah.
- 130 pengujian resmi berhasil dijalankan.
- 4 pengujian mahasiswa berhasil dijalankan.
- Demo obrolan berhasil dijalankan.
- Fitur streaming, pembatasan kuota, dan penyaringan data dapat diuji.
- Aplikasi dapat menampilkan respons dan menangani simulasi kegagalan layanan.

Seluruh hasil pengujian disimpan pada folder `docs/verification/` dan `evidence/output/`.

## 7. Bukti Praktikum

Bukti pengerjaan disimpan pada folder `evidence/screenshots/`.

| No. | Nama Screenshot | Keterangan |
|---|---|---|
| 01 | `10-01-tampilan-awal.png` | Tampilan awal aplikasi |
| 02 | `10-02-setelah-pesan.png` | Setelah mengirim pesan |
| 03 | `10-03-kuota-berkurang.png` | Perubahan kuota |
| 04 | `10-04-simulasi-gagal.png` | Simulasi kegagalan |
| 05 | `10-05-kuota-dua-permintaan.png` | Pembatasan dua permintaan |
| 06 | `10-06-filter-api-key.png` | Penyaringan API Key |
| 07 | `10-07-penyamaran-email.png` | Penyamaran email |
| 08 | `10-08-mode-ringkas.png` | Mode respons ringkas |
| 09 | `10-09-test-provider-mahasiswa.png` | Pengujian provider mahasiswa |
| 10 | `10-10-test-provider-gagal.png` | Pengujian provider gagal |
| 11 | `10-11-provider-buatan-di-aplikasi.png` | Provider buatan pada aplikasi |
| 12 | `10-12-flutter-analyze.png` | Hasil Flutter Analyze |
| 13 | `10-13-test-resmi.png` | Hasil pengujian resmi |
| 14 | `10-14-test-mahasiswa.png` | Hasil pengujian mahasiswa |
| 15 | `10-15-demo-obrolan.png` | Demo obrolan AI |
| 16 | `10-16-streaming-40ms.png` | Streaming dengan jeda 40 ms |
| 17 | `10-17-streaming-400ms.png` | Streaming dengan jeda 400 ms |

## 8. Refleksi Modul 10

### 1. Mengapa starter tidak membutuhkan API Key?

Menurut saya, starter tidak membutuhkan API Key karena layanan AI yang digunakan pada tahap ini masih berupa simulasi atau provider lokal. Tujuannya agar mahasiswa dapat memahami alur kerja aplikasi terlebih dahulu tanpa harus menggunakan layanan AI dari pihak luar. Dengan begitu, proses pembelajaran bisa dilakukan tanpa harus mengatur akun dan kredensial API.

### 2. Apa perbedaan streaming 40 ms dan 400 ms?

Perbedaannya terletak pada kecepatan kemunculan respons. Pada jeda 40 ms, teks muncul lebih cepat dan terasa lebih lancar. Sedangkan pada jeda 400 ms, teks muncul lebih lambat sehingga proses streaming lebih terlihat. Dari percobaan tersebut, saya memahami bahwa pengaturan jeda dapat memengaruhi pengalaman pengguna saat menerima respons AI.

### 3. Bagaimana pengaruh Mode Ringkas terhadap streaming?

Mode Ringkas membuat respons AI menjadi lebih pendek sehingga jumlah teks yang ditampilkan juga lebih sedikit. Hal ini dapat membuat proses streaming terasa lebih cepat karena teks yang harus ditampilkan tidak terlalu banyak. Menurut saya, mode ini cocok digunakan ketika pengguna hanya membutuhkan jawaban langsung tanpa penjelasan panjang.

### 4. Mengapa data NIK atau kartu perlu ditolak dan nama perlu disamarkan?

Data seperti NIK dan nomor kartu termasuk informasi pribadi yang tidak boleh dibagikan sembarangan. Jika data tersebut dikirim ke layanan AI tanpa penyaringan, ada risiko informasi pribadi tersebar atau disalahgunakan. Oleh karena itu, aplikasi perlu memeriksa data sebelum dikirim. Data tertentu dapat ditolak, sedangkan informasi seperti nama atau email dapat disamarkan sesuai kebutuhan.

### 5. Mengapa kredensial harus diperiksa dan apa hubungannya dengan keamanan Modul 09?

Kredensial seperti API Key harus dijaga karena dapat digunakan untuk mengakses layanan tertentu. Jika kredensial terlihat oleh orang lain, ada kemungkinan layanan digunakan tanpa izin. Hal ini berkaitan dengan materi keamanan pada Modul 09, yaitu pentingnya menjaga informasi sensitif dan menghindari penyimpanan data rahasia secara langsung di dalam aplikasi. Oleh karena itu, API Key tidak boleh ditampilkan atau dibagikan sembarangan.

### 6. Mengapa keterbatasan AI perlu dijelaskan secara jujur?

AI tidak selalu memberikan jawaban yang benar dan sesuai dengan kebutuhan pengguna. Terkadang respons yang dihasilkan bisa kurang tepat atau memiliki informasi yang keliru. Karena itu, pengembang perlu menjelaskan keterbatasan AI agar pengguna tidak langsung menganggap semua jawaban sebagai informasi yang pasti benar. Menurut saya, hal ini penting supaya pengguna tetap bisa berpikir kritis saat menggunakan aplikasi berbasis AI.

## 9. Kesimpulan

Melalui praktikum Modul 10, saya memahami bahwa integrasi AI pada aplikasi Flutter tidak hanya berkaitan dengan mengirim dan menerima pesan. Ada beberapa hal lain yang perlu diperhatikan, seperti pengelolaan kuota, streaming respons, penyaringan data sensitif, keamanan API Key, serta penanganan kesalahan.

Dari praktikum ini, saya mendapatkan pengalaman dalam mengembangkan aplikasi yang lebih terstruktur dan memahami pentingnya keamanan serta kenyamanan pengguna ketika menggunakan fitur AI.

---

**Catatan:** Proyek tambahan integrasi 9router dan Ollama diletakkan secara terpisah pada folder `modul-10-api-9router`, sehingga tidak digabungkan dengan starter mahasiswa pada Classroom Template.