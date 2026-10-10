# Laporan Praktikum Modul 05 — Tugas Praktikum

## 1. Identitas Mahasiswa

| Informasi | Data |
|---|---|
| Nama | Bunga Hendryanda Ramadhani |
| NIM | 362558302031 |
| Program Studi | Sarjana Terapan Teknologi Rekayasa Perangkat Lunak (TRPL) |
| Kelas | 2CTRPL |
| Mata Kuliah | Pemrograman Perangkat Bergerak |
| Modul | Modul 05 — Penyimpanan Lokal dan SQLite |

## 2. Tujuan Praktikum

Pada modul ini saya membuat aplikasi Tugas Praktikum. Di Fase A, data tugas disimpan menggunakan SharedPreferences dalam bentuk JSON. Aplikasi memiliki tampilan loading, daftar tugas, keadaan kosong, dan keadaan gagal. Pengguna juga bisa menambah tugas, menandai tugas selesai, menghapus tugas, dan mengurungkan penghapusan.

Di Fase B, saya mempelajari cara memisahkan sumber data menggunakan repository, lalu membandingkan penyimpanan SharedPreferences dengan SQLite. Saya juga mencoba migrasi database saat struktur tabel berubah.

## 3. Cara Menjalankan Aplikasi

### Persiapan

Buka folder `05-week-5` di VS Code. Pastikan terminal berada di folder yang sama dengan `pubspec.yaml`, lalu jalankan:

```powershell
flutter pub get
flutter analyze
```

### Menjalankan Fase A

Untuk menjalankan aplikasi Fase A di Chrome menggunakan port tetap:

```powershell
flutter run -d web-server --web-port=8080 -t lib/modul_05/modul_05_app.dart
```

Setelah server aktif, buka `http://localhost:8080` di Chrome.

Untuk menampilkan keadaan loading lebih lama:

```powershell
flutter run -d web-server --web-port=8080 -t lib/modul_05/modul_05_app.dart --dart-define=LAMBAT=true
```

### Menjalankan Fase B

Periksa perangkat yang tersedia:

```powershell
flutter devices
```

Jalankan aplikasi pengayaan pada emulator atau perangkat yang mendukung SQLite. Ganti `ID_PERANGKAT` dengan ID perangkat yang muncul dari perintah sebelumnya:

```powershell
flutter run -d ID_PERANGKAT -t lib/pengayaan/modul_05/modul_05_pengayaan_app.dart
```

Pada project ini, menjalankan SQLite langsung di Chrome pernah menampilkan pesan `databaseFactory not initialized`. Karena itu, pengujian SQLite langsung perlu dilakukan di perangkat atau target yang didukung, sedangkan pengujian migrasi memakai FFI.

## 4. Struktur File Modul 05

```text
lib/
├── modul_05/                              # Fase A
│   ├── models/
│   │   └── task.dart
│   ├── services/
│   │   └── task_storage.dart
│   ├── widgets/
│   │   └── task_tile.dart
│   ├── screens/
│   │   └── task_list_screen.dart
│   └── modul_05_app.dart
│
└── pengayaan/
    └── modul_05/                          # Fase B
        ├── database/
        │   └── app_database.dart
        ├── repositories/
        │   ├── task_repository.dart
        │   ├── prefs_task_repository.dart
        │   └── sqlite_task_repository.dart
        ├── screens/
        │   └── task_list_pengayaan_screen.dart
        └── modul_05_pengayaan_app.dart

test/
├── modul_05_test.dart
├── pengayaan_modul_05_test.dart
└── latihan_5_migrasi_v3_test.dart

evidence/
├── screenshots/
└── output/
```

## 5. Penjelasan Fase A

### Model dan penyimpanan

`Task` menyimpan data tugas seperti ID, judul, mata kuliah, status selesai, tanggal dibuat, dan prioritas. `toJson()` mengubah tugas menjadi data JSON, sedangkan `fromJson()` membaca data JSON menjadi objek `Task`. `copyWith()` digunakan untuk membuat perubahan tanpa mengubah objek lama secara langsung.

`TaskStorage` menjadi satu tempat untuk membaca dan menyimpan data. Daftar disimpan di SharedPreferences sebagai JSON. Saat data belum ada, aplikasi menampilkan data contoh. Kalau JSON rusak, aplikasi menampilkan keadaan gagal agar masalahnya tidak disembunyikan.

### Tampilan dan interaksi

`TaskTile` menampilkan satu tugas dan memberi tahu layar saat statusnya diubah. `TaskListScreen` mengatur daftar, ringkasan jumlah tugas, form tambah tugas, loading, error, keadaan kosong, dan penyimpanan otomatis.

Setelah tugas ditambah, diubah statusnya, atau dihapus, daftar disimpan lagi. Jika penyimpanan gagal, daftar di layar dikembalikan ke kondisi sebelumnya. Form memeriksa judul dan mata kuliah menggunakan `trim()` supaya input yang hanya berisi spasi tidak diterima.

### Empat keadaan layar

- **Loading:** muncul saat aplikasi sedang membaca data.
- **Data:** menampilkan daftar tugas dan ringkasan jumlah tugas.
- **Kosong:** muncul jika daftar tidak memiliki tugas.
- **Gagal:** menampilkan pesan saat data tidak dapat dibaca, beserta tombol Coba Lagi dan Hapus Data Rusak.

## 6. Penjelasan Fase B

Fase B dibuat di folder `lib/pengayaan/modul_05/`. Folder Fase A di `lib/modul_05/` tetap dipisahkan.

`AppDatabase` mengatur file database, pembuatan tabel, dan migrasi. `TaskRepository` menjadi kontrak untuk operasi data. `PrefsTaskRepository` menggunakan `TaskStorage`, sedangkan `SqliteTaskRepository` menggunakan SQLite. `TaskListPengayaanScreen` memakai repository yang diberikan, sehingga tampilan tidak harus mengetahui cara penyimpanan secara langsung.

Pada migrasi versi 3, versi skema dinaikkan dari 2 menjadi 3 dan kolom `catatan` ditambahkan dengan nilai default string kosong. Test migrasi membuat database versi 2, memasukkan data lama, lalu membukanya dengan versi 3 untuk memeriksa apakah data lama tetap ada dan kolom baru sudah tersedia.

## 7. Hasil Pengujian

Hasil di bawah ini berdasarkan pemeriksaan yang sudah dijalankan selama praktikum. Jalankan kembali perintah pada bagian ini sebelum pengumpulan akhir dan perbarui catatannya jika hasil berubah.

## Hasil Pemeriksaan Terakhir

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | Lulus. Tidak ditemukan masalah kode. |
| `flutter test test/modul_05_test.dart` | Lulus. Semua test Fase A berhasil. |
| `flutter test test/pengayaan_modul_05_test.dart` | Lulus. Semua test Fase B berhasil. |
| `flutter test test/latihan_5_migrasi_v3_test.dart --reporter expanded` | Lulus. Migrasi versi 2 ke 3 berhasil diuji dan data lama tetap ada. |
| `flutter test` | Lulus. Semua test dalam project berhasil. |
| Pengujian SharedPreferences dan SQLite | Sudah diuji. Screenshot hasil pergantian sumber data disimpan di folder `evidence/screenshots/`. |

## 8. Latihan Mandiri

### Latihan 1 — Tombol kembali dan menutup aplikasi

Pada latihan ini, saya membandingkan dua cara membuka aplikasi kembali. Pertama, saya keluar dari layar dengan tombol kembali lalu membuka aplikasi lagi. Kedua, saya menutup aplikasi sepenuhnya, lalu menjalankannya lagi. Untuk versi web, saya menggunakan alamat yang sama dan membedakan menutup tab dengan menghentikan server Flutter. Hasil akhirnya dicatat dari data dan status tugas yang benar-benar terlihat setelah aplikasi dibuka kembali.

### Latihan 2 — Waktu terakhir disimpan

Saya menambahkan kunci `modul_05_waktu_simpan` di `TaskStorage`. Setelah daftar berhasil disimpan, aplikasi menyimpan waktu menggunakan `DateTime.now().toIso8601String()`. Waktu dibaca kembali sebagai `DateTime` dan ditampilkan di bawah AppBar. Dengan begitu, pengguna bisa melihat kapan daftar terakhir berhasil disimpan.

### Latihan 3 — Counter jumlah record yang ditulis

Saya menambahkan counter `jumlahTugasDitulis` untuk menghitung berapa banyak tugas yang ditulis setiap kali `simpan()` berhasil. Karena Fase A menyimpan ulang seluruh daftar, saat daftar berisi lima tugas lalu satu status diubah, lima record ditulis lagi, bukan hanya satu record. Counter ini hanya berlaku selama aplikasi berjalan dan kembali dari awal setelah aplikasi dimulai ulang.

### Latihan 4 — Cadangan JSON yang rusak

Pada latihan ini, saya menambahkan mode pemulihan khusus. Jika JSON tidak bisa dibaca dan mode latihan dipilih, isi JSON yang rusak disalin ke kunci cadangan terlebih dahulu. Setelah cadangan berhasil dibuat, daftar aktif disimpan sebagai `[]` dan aplikasi menampilkan pesan bahwa data sudah dicadangkan. Pemanggilan normal tetap menampilkan keadaan gagal ketika JSON rusak. Test `test/modul_05_test.dart` untuk latihan ini sudah lulus pada hasil yang dilaporkan.

### Latihan 5 — Migrasi SQLite versi 3

Saya menaikkan versi skema database menjadi 3 dan menambahkan kolom `catatan` dengan nilai default string kosong. Blok migrasi versi 2 tetap dipertahankan, lalu blok migrasi versi 3 ditambahkan di bawahnya. Test membuat database versi 2 terlebih dahulu, menyimpan satu tugas lama, lalu membukanya dengan versi 3. Hasil test yang dijalankan menunjukkan `All tests passed!`, sehingga data lama tetap ada dan kolom `catatan` berhasil ditambahkan dalam pengujian.

## 9. Jawaban Pertanyaan Refleksi

### 1. Apa yang lebih mudah dan lebih sulit pada SharedPreferences dan SQLite?

Menurut saya, SharedPreferences lebih mudah saat menambah field karena data disimpan sebagai JSON dan tidak perlu mengubah struktur tabel. Namun, saat daftar makin banyak, aplikasi perlu membaca, mengubah, dan menyimpan ulang seluruh daftar. Pada SQLite, perubahan struktur perlu migrasi dan kenaikan versi skema, jadi bagian itu lebih rumit. Sebaliknya, SQLite lebih mudah untuk mengambil data tertentu atau menghitung jumlah baris langsung dari database.

### 2. Mengapa `TaskStorage.muat()` melempar `FormatException` saat JSON rusak?

Menurut saya, error harus ditampilkan supaya pengguna tahu kalau data yang disimpan tidak bisa dibaca. Kalau aplikasi langsung mengembalikan daftar kosong, pengguna bisa mengira semua tugas hilang atau terhapus. Dengan menampilkan error, aplikasi bisa menyediakan pilihan untuk mencoba lagi atau menghapus data yang rusak.

### 3. Mengapa tampilan diperbarui sebelum data disimpan?

Menurut saya, cara itu membuat aplikasi terasa lebih cepat karena perubahan langsung terlihat setelah tombol ditekan. Kalau penyimpanan gagal, daftar dikembalikan ke keadaan sebelumnya supaya tampilan tidak menunjukkan data yang sebenarnya gagal disimpan. Untuk tindakan yang sangat penting, misalnya pembayaran, lebih tepat menunggu konfirmasi penyimpanan berhasil sebelum menampilkan hasil akhir.

### 4. Operasi Fase A apa yang biayanya bertambah jika jumlah tugas banyak?

Pertama, memuat daftar karena semua JSON harus dibaca dan diubah menjadi objek tugas. Kedua, menyimpan perubahan karena seluruh daftar ditulis ulang. Ketiga, menghitung jumlah tugas karena aplikasi perlu membaca daftar untuk menghitung panjang atau statusnya. SQLite bisa mengambil data dengan query tertentu dan menghitung jumlah baris memakai `COUNT(*)`, sehingga tidak selalu perlu memindahkan semua tugas ke memori.

### 5. Apa risiko jika `TaskRepository` memiliki metode yang hanya cocok untuk satu penyimpanan?

Menurut saya, kontrak repository menjadi sulit dipakai bersama kalau ditambah metode yang hanya cocok untuk satu jenis penyimpanan. Implementasi lain bisa dipaksa membuat cara yang tidak cocok atau menjadi lebih rumit. Akibatnya, tujuan memisahkan tampilan dari sumber data jadi berkurang. Karena itu Fase A perlu stabil terlebih dahulu sebelum Fase B ditambahkan.

## 10. Daftar Bukti

Simpan screenshot asli di `evidence/screenshots/` dan keluaran perintah di `evidence/output/`. Jangan membuat file screenshot kosong; ambil gambar dari aplikasi atau terminal yang benar-benar berjalan.

### Screenshot Fase A

- `fase-a-01-memuat.png` — indikator loading dan teks penjelas.
- `fase-a-02-daftar.png` — daftar tugas beserta ringkasan.
- `fase-a-03-kosong.png` — keadaan ketika daftar kosong.
- `fase-a-04-gagal.png` — pesan error dan tombol Coba Lagi serta Hapus Data Rusak.
- `fase-a-05-pulih.png` — keadaan setelah data rusak dihapus atau dipulihkan.
- `fase-a-06-persistensi.png` — daftar dan status setelah aplikasi dibuka kembali.

### Screenshot Fase B dan latihan

- `fase-b-01-sharedpreferences.png` — dua tugas pada sumber SharedPreferences.
- `fase-b-02-sqlite.png` — tugas dan jumlah data pada sumber SQLite.
- `fase-b-03-kembali-prefs.png` — daftar SharedPreferences tetap ada setelah berganti sumber.
- `latihan-1-persistensi.png` — bukti percobaan persistensi.
- `latihan-2-waktu-simpan.png` — waktu terakhir disimpan di bawah AppBar.
- `latihan-3-counter.png` — jumlah record yang ditulis.
- `latihan-4-cadangan-json.png` — pesan bahwa data rusak sudah dicadangkan.
- `latihan-5-migrasi-v3-test.png` — terminal yang menampilkan test migrasi lulus.

### Output pemeriksaan

- `evidence/output/flutter_analyze.txt`
- `evidence/output/fase_a_test.txt`
- `evidence/output/fase_b_test.txt`
- `evidence/output/latihan_5_migrasi_test.txt`

Perbarui file output dengan hasil terbaru sebelum ZIP dibuat. Jangan mengubah output error menjadi seolah-olah lulus.

## 11. Catatan Penggunaan AI

Saya menggunakan ChatGPT sebagai bantuan untuk memahami pesan error, membahas perbaikan kode, dan menyusun langkah pengujian. Saya tetap menjalankan kode, memeriksa hasil `flutter analyze`, menjalankan test, dan memeriksa tampilan aplikasi di komputer sendiri. Hasil akhir yang dicantumkan pada README mengikuti keluaran yang benar-benar saya dapatkan.

| Bagian | Alat | Tujuan | Pengecekan yang dilakukan |
|---|---|---|---|
| `lib/modul_05/services/task_storage.dart` | ChatGPT | Membantu memahami JSON, SharedPreferences, waktu simpan, counter, dan pemulihan JSON rusak | Menjalankan `flutter analyze`, test Fase A, dan memeriksa perilaku aplikasi |
| `lib/modul_05/screens/task_list_screen.dart` | ChatGPT | Membantu memperbaiki form, controller, dan tampilan tambahan latihan | Menjalankan aplikasi dan mencoba tambah tugas serta pemulihan data |
| `lib/pengayaan/modul_05/database/app_database.dart` | ChatGPT | Membantu memahami versi skema dan migrasi SQLite | Menjalankan test migrasi versi 2 ke versi 3 |
| `test/latihan_5_migrasi_v3_test.dart` | ChatGPT | Membantu menyusun skenario test migrasi | Menjalankan test dan memeriksa hasil data lama serta kolom baru |

## 12. Kesimpulan

Dari Modul 05, saya belajar menyimpan daftar tugas menggunakan SharedPreferences dan JSON, menangani keadaan loading, kosong, dan error, serta menguji apakah data tetap ada setelah aplikasi dibuka kembali. Saya juga belajar bahwa SQLite membutuhkan pengelolaan versi skema ketika struktur tabel berubah. Test migrasi versi 3 sudah berhasil dijalankan, sedangkan semua test dan bukti lain perlu diperiksa sekali lagi sebelum project dikumpulkan.
