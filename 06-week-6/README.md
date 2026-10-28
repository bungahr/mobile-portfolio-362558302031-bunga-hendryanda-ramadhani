# Week 6 — Authentication & Session Security

## 1. Identitas

- **Nama:** Bunga Hendryanda Ramadhani
- **Program Studi:** D4 Teknologi Rekayasa Perangkat Lunak
- **Kelas:** 2CTRPL
- **Mata Kuliah:** Pemrograman Perangkat Bergerak
- **Modul:** 06 — Authentication & Session Security

## 2. Tujuan Praktikum

Praktikum ini bertujuan memahami proses login, validasi data, pengelolaan sesi pengguna, dan keamanan penyimpanan token pada aplikasi Flutter.

## 3. Implementasi Fase A

Fase A membahas autentikasi dan pengelolaan sesi dasar, meliputi:

- Validasi email dan kata sandi.
- Login berhasil dan gagal.
- Penanganan akun terkunci, akun belum diverifikasi, dan gangguan server.
- Penyimpanan sesi menggunakan memori aplikasi.
- Logout dan pemulihan sesi.
- Hitung mundur masa berlaku sesi.
- Pembatalan proses login dan perlindungan akses halaman.

## 4. Implementasi Fase B

Fase B merupakan pengembangan penyimpanan dan pengelolaan sesi, meliputi:

- Penyimpanan sesi menggunakan memori, SharedPreferences, dan Secure Storage.
- Pemulihan dan pembaruan sesi.
- Diagnostik penyimpanan.
- Simulasi risiko token dicuri.
- Gerbang sesi untuk membatasi akses halaman profil.

## 5. Akun Pengujian

| Skenario | Email |
|---|---|
| Login berhasil | `student@trpl.test` |
| Akun terkunci | `terkunci@trpl.test` |
| Gangguan server | `gangguan@trpl.test` |
| Akun belum diverifikasi | `verifikasi@trpl.test` |

Kata sandi mengikuti konfigurasi akun pada `AuthApi`.

## 6. Cara Menjalankan Aplikasi

Jalankan perintah berikut dari folder `06-week-6`.

Mengambil dependensi:

```bash
flutter pub get
```

Menjalankan Fase A:

```bash
flutter run
```

Menjalankan Fase A dengan simulasi login lambat:

```bash
flutter run --dart-define=LAMBAT=true
```

Menjalankan Fase B:

```bash
flutter run -t lib/main_pengayaan.dart
```

## 7. Pengujian

Analisis kode:

```bash
flutter analyze
```

Menjalankan seluruh pengujian:

```bash
flutter test
```

Pengujian mencakup model sesi, autentikasi, penyimpanan sesi, validasi form, dan perilaku aplikasi sesuai pengujian yang tersedia.

## 8. Bukti Praktikum

Screenshot disimpan pada `evidence/screenshots/`, sedangkan hasil analisis dan pengujian disimpan pada `evidence/output/`.

Bukti mencakup validasi form, login berhasil dan gagal, logout, pembatalan login, hitung mundur sesi, penyimpanan Fase B, diagnostik penyimpanan, simulasi token dicuri, dan akses profil dengan sesi aktif.

## 9. Jawaban Pertanyaan Refleksi

### 1. Mengapa aplikasi perlu memeriksa masa berlaku sesi?

Menurut saya, pemeriksaan masa berlaku sesi diperlukan supaya pengguna tidak terus menggunakan sesi yang sudah kedaluwarsa. Jika sesi sudah berakhir, aplikasi sebaiknya meminta pengguna login kembali agar akses tetap terkontrol.

### 2. Apa perbedaan penyimpanan sesi menggunakan memori, SharedPreferences, dan Secure Storage?

Penyimpanan memori hanya bertahan selama proses aplikasi berjalan. SharedPreferences dapat menyimpan data agar masih tersedia setelah aplikasi dibuka kembali, tetapi bukan pilihan khusus untuk melindungi token rahasia. Secure Storage dirancang untuk menyimpan data sensitif dengan memanfaatkan mekanisme keamanan platform.

### 3. Mengapa token tidak sebaiknya ditampilkan secara langsung?

Token dapat digunakan sebagai bukti autentikasi. Jika token diketahui orang lain dan masih berlaku, token tersebut berpotensi disalahgunakan. Karena itu, token sebaiknya disamarkan saat ditampilkan dan disimpan menggunakan mekanisme yang sesuai.

### 4. Apa perbedaan membatalkan login dan mengabaikan hasil login?

Membatalkan login berarti berusaha menghentikan proses yang sedang berlangsung. Sementara itu, mengabaikan hasil login berarti prosesnya mungkin tetap berjalan, tetapi hasilnya tidak lagi digunakan oleh aplikasi. Perbedaannya penting agar hasil login yang sudah tidak relevan tidak mengubah status aplikasi.

### 5. Mengapa halaman profil harus dilindungi oleh gerbang sesi?

Gerbang sesi memastikan halaman yang membutuhkan autentikasi hanya dapat dibuka ketika sesi masih aktif. Pemeriksaan tidak cukup hanya dilakukan dengan menyembunyikan tombol, karena halaman juga harus memeriksa status sesi saat diakses secara langsung.