# Modul 11 — Optimasi Performa Flutter

## Identitas
- Nama: Bunga Hendryanda Ramadhani
- Kelas: 2CTRPL
- Mata Kuliah: Pemrograman Perangkat Bergerak

## Tujuan Praktikum
Praktikum ini bertujuan memahami cara mengelola dan menampilkan data dalam jumlah besar pada aplikasi Flutter. Selain itu, praktikum ini mempelajari penggunaan `ListView.builder`, filter data, pagination, serta pengujian untuk memastikan aplikasi berjalan dengan baik.

## Fase A — Daftar Tugas dan Filter

Pada fase ini dibuat aplikasi daftar tugas yang menampilkan 1.000 data tugas. Data memiliki beberapa mata kuliah dan status pengerjaan.

Implementasi yang dilakukan:
- Membuat model `TugasPerforma`.
- Membuat sumber data contoh sebanyak 1.000 tugas.
- Menggunakan `ListView.builder` untuk menampilkan daftar.
- Menambahkan pencarian berdasarkan kata kunci.
- Menambahkan filter berdasarkan status tugas.
- Menampilkan jumlah data yang sesuai dengan filter.

### Penggunaan ListView.builder
`ListView.builder` digunakan agar widget daftar dibuat sesuai kebutuhan tampilan ketika pengguna menggulir halaman. Dengan cara ini, aplikasi tidak perlu membuat seluruh 1.000 kartu tugas sekaligus.

## Fase B — Pagination

Pada fase ini dibuat fitur pemuatan data secara bertahap menggunakan pagination.

Implementasi yang dilakukan:
- Memuat data berdasarkan halaman.
- Menampilkan indikator ketika data sedang dimuat.
- Menangani kondisi gagal memuat data.
- Menyediakan tombol untuk mencoba kembali.
- Mencegah pemanggilan halaman yang sama secara bersamaan.
- Menghentikan pemuatan ketika seluruh data sudah ditampilkan.

### Perbandingan ListView.builder dan Pagination

`ListView.builder` mengatur pembuatan widget agar tidak seluruh item dibuat sekaligus. Sementara itu, pagination mengatur pengambilan data secara bertahap berdasarkan halaman.

Jadi, keduanya memiliki fungsi yang berbeda tetapi bisa digunakan bersama untuk membantu aplikasi mengelola daftar data yang besar.

## Latihan Mandiri — Filter Mata Kuliah

Pada latihan mandiri ditambahkan filter berdasarkan mata kuliah menggunakan `ChoiceChip`.

Perubahan yang dilakukan:
- Menambahkan properti `mataKuliah` pada `KriteriaFilter`.
- Memperbarui fungsi `saringTugas`.
- Memperbarui fungsi `salinDengan`.
- Menampilkan pilihan mata kuliah berdasarkan `daftarMataKuliahContoh`.
- Menggabungkan filter mata kuliah dan status menggunakan logika AND.

Hasil pengujian menunjukkan:
- Seluruh data berjumlah 1.000 tugas.
- Filter Basis Data menampilkan 125 tugas.
- Filter Basis Data dan status Selesai menampilkan 31 tugas.
- Penyaringan tidak mengubah data sumber.

## Pengujian

Pengujian dilakukan menggunakan Flutter Test dan Flutter Analyze.

| Pengujian | Hasil |
|---|---|
| Test bawaan Modul 11 | 15 pengujian berhasil |
| Test latihan mandiri | 2 pengujian berhasil |
| Flutter Analyze | No issues found |

Seluruh 17 pengujian berhasil dijalankan tanpa kegagalan.

## Catatan Pengukuran Performa

Pengamatan dilakukan menggunakan data contoh sebanyak 1.000 tugas.

Beberapa hal yang diamati:
- Penggunaan `ListView.builder` untuk menghindari pembuatan seluruh kartu sekaligus.
- Pemuatan data bertahap pada fitur pagination.
- Perubahan jumlah data setelah filter diterapkan.
- Penanganan loading dan error ketika mengambil data.

Pengamatan ini menunjukkan bahwa pengelolaan widget dan pemuatan data perlu diperhatikan ketika aplikasi menampilkan data dalam jumlah besar.

## Refleksi

Dari praktikum ini saya memahami bahwa menampilkan banyak data tidak harus dilakukan sekaligus. `ListView.builder` membantu mengatur pembuatan widget, sedangkan pagination membantu mengambil data secara bertahap.

Saya juga memahami cara menggabungkan beberapa filter agar hasil pencarian lebih sesuai dengan kebutuhan pengguna. Pengujian membantu memastikan fitur yang dibuat berjalan sesuai harapan.

## Pertanyaan Refleksi

**1. Bagian mana dari `build()` yang dijalankan ulang setiap kali kueri berubah, dan apakah itu perlu dioptimasi?**

Ketika kueri berubah, fungsi `setState()` dipanggil sehingga `build()` pada halaman daftar tugas dijalankan kembali. Bagian yang diperbarui meliputi proses penyaringan data dan tampilan daftar tugas, termasuk jumlah hasil pencarian. Untuk data 1.000 tugas, proses ini masih dapat berjalan dengan baik. Namun, jika jumlah data semakin besar, proses penyaringan dapat dioptimasi agar tidak dilakukan berulang kali ketika tidak diperlukan.

**2. Mengapa `ListView.builder` tidak sama dengan pagination? Kapan aplikasi Anda membutuhkan pagination?**

`ListView.builder` digunakan untuk membuat widget sesuai kebutuhan tampilan, sehingga tidak semua kartu dibuat sekaligus. Sedangkan pagination digunakan untuk mengambil data secara bertahap berdasarkan halaman. Aplikasi membutuhkan pagination ketika jumlah data sangat banyak atau data berasal dari server, sehingga pengambilan seluruh data sekaligus dapat membebani jaringan dan memori.

**3. Apa satu faktor lingkungan yang dapat membuat hasil pengukuran Anda berbeda di perangkat lain?**

Salah satu faktornya adalah spesifikasi perangkat, terutama kemampuan prosesor dan RAM. Perangkat dengan spesifikasi lebih rendah mungkin membutuhkan waktu lebih lama untuk memproses dan menampilkan data dibandingkan perangkat dengan spesifikasi lebih tinggi.

**4. Pada grafik frame yang Anda rekam (atau pada contoh di dokumentasi DevTools jika Anda memakai jalur C), batang mana yang lebih sering melewati anggaran, UI atau Raster, dan tahap pipeline mana yang diwakilinya?**

Saya belum memiliki hasil grafik frame DevTools yang dapat dijadikan bukti untuk menentukan apakah batang UI atau Raster yang lebih sering melewati anggaran. Pada grafik DevTools, UI menunjukkan waktu yang digunakan untuk membangun widget, layout, dan pekerjaan UI lainnya. Sementara itu, Raster menunjukkan waktu untuk menggambar dan merender tampilan ke layar. Jadi, bagian yang melewati anggaran harus ditentukan berdasarkan grafik yang direkam atau contoh dokumentasi DevTools yang digunakan.