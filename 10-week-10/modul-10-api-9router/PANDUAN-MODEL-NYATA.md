# Demonstrasi dosen: integrasi model AI nyata

## 1. Tujuan dan pilihan implementasi

Demo membandingkan aplikasi yang sama menggunakan simulator dan inferensi model. `main.dart` tetap menjalankan materi asli. `main_kunci.dart` tetap menjalankan kunci latihan. Entry point baru `main_ai.dart` menyediakan pilihan simulator dan Ollama, memakai kontrak serta ViewModel dari Modul 10 tanpa mengubah keduanya.

Alur model nyata: Flutter mengirim teks yang telah diperiksa ViewModel ke endpoint lokal `/api/chat`. Ollama menjalankan model, kemudian mengirim baris NDJSON. Adapter `LayananOllama` mendekode setiap baris, mengambil `message.content`, dan memancarkannya melalui `Stream<String>`. ViewModel memperbarui pesan serta status seperti pada simulator.

Ollama adalah server inferensi, Qwen adalah keluarga model. Keduanya berbeda dari simulator berbasis kata kunci. Demo ini tidak melatih atau melakukan fine-tuning model.

## 2. Persyaratan yang perlu diperiksa dahulu

Pemeriksaan komputer pengembangan menunjukkan macOS 13.7.8. Dokumentasi Ollama saat penyusunan panduan mensyaratkan macOS 14 atau lebih baru untuk versi saat ini. Jangan menganggap instalasi terbaru dapat berjalan pada komputer ini. Pilih komputer lain yang didukung atau server Linux milik dosen/laboratorium. Tidak perlu mengubah OS atau memasang versi lama tanpa evaluasi kompatibilitas.

Ollama belum ditemukan pada PATH dan endpoint lokal belum dapat dihubungi saat penyiapan. Model tidak diunduh otomatis. Contoh awal memakai `qwen2.5:1.5b`; halaman model mencantumkan unduhan sekitar 986 MB, sedangkan kebutuhan RAM saat inferensi lebih besar dan bergantung konfigurasi. Model kecil dipilih untuk demonstrasi, bukan jaminan akurasi atau kecepatan tertentu.

## 3. Menyiapkan Ollama pada perangkat yang didukung

Instal dari https://ollama.com/download dan periksa persyaratan platform. Pada terminal perangkat model:

```bash
ollama --version
ollama pull qwen2.5:1.5b
```

Pengunduhan memerlukan internet dan ruang disk. Setelah model tersedia, inferensi model lokal tidak memerlukan akun atau kunci provider. Jalankan server hanya jika belum aktif:

```bash
OLLAMA_HOST=127.0.0.1:11434 OLLAMA_NO_CLOUD=1 ollama serve
```

Jangan menjalankan dua server pada port sama. Aplikasi desktop Ollama mungkin sudah mengaktifkan server. Gunakan `ollama list` untuk memastikan model tersedia dan `ollama ps` untuk melihat model yang dimuat. Unduhan model berbeda dari pengiriman prompt: panduan ini menggunakan model lokal, bukan nama model cloud.

Uji API pada perangkat model sebelum menjalankan Flutter:

```bash
curl -N http://127.0.0.1:11434/api/chat \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen2.5:1.5b","messages":[{"role":"user","content":"Jelaskan Flutter dalam dua kalimat bahasa Indonesia."}],"stream":true}'
```

Hasil yang diperiksa: beberapa baris JSON dengan `message.content`, diikuti penanda `done: true`. Isi jawaban dapat berbeda pada setiap inferensi. Pemuatan pertama dapat lebih lambat. Jangan menyalin output contoh sebagai bukti inferensi.

## 4. Menghubungkan komputer macOS 13 ke perangkat model

Jika memakai server Linux atau komputer lain dengan akses SSH yang telah diizinkan, jalankan server Ollama di loopback perangkat tersebut. Dari terminal komputer Flutter, gunakan tunnel:

```bash
ssh -N -L 11434:127.0.0.1:11434 nama_pengguna@alamat_perangkat_model
```

Ganti identitas tujuan dengan perangkat yang dimiliki atau diizinkan untuk diakses. Biarkan terminal tunnel terbuka. Setelah itu, perintah curl pada bagian 3 dijalankan dari komputer Flutter ke alamat localhost yang sama. Pada skenario ini, teks diproses di perangkat tujuan SSH, bukan di Mac yang menjalankan Flutter. Jelaskan lokasi pemrosesan kepada mahasiswa.

Tidak perlu membuka Ollama ke internet, memakai bind 0.0.0.0, atau membuat endpoint publik tanpa autentikasi. Tutup tunnel saat demonstrasi selesai. Tunnel bukan solusi untuk menjalankan binary Ollama yang tidak kompatibel pada macOS 13; inferensi memang dijalankan di perangkat lain.

## 5. Menjalankan aplikasi dosen

Jalankan dari akar `modul_10_integrasi_ai`. Jika folder platform belum ada, ikuti langkah `flutter create` pada README proyek. Untuk macOS Ventura, gunakan toolchain yang telah dipin:

```bash
nix-shell ../shell.nix
flutter pub get
flutter run -d chrome -t lib/main_ai.dart \
  --web-hostname 127.0.0.1 --web-port 7080 \
  --dart-define=OLLAMA_MODEL=qwen2.5:1.5b \
  --dart-define=OLLAMA_URL=http://127.0.0.1:11434/api/chat
```

Mode awal adalah simulator. Pilih “Ollama lokal / inferensi model nyata” setelah endpoint berhasil diuji. Pergantian layanan menghapus riwayat tampilan agar hasil simulator dan model tidak tercampur. Dropdown tidak dapat diubah selama permintaan berlangsung.

`OLLAMA_MODEL` dan `OLLAMA_URL` bukan rahasia. Nilai `--dart-define` tetap dapat diekstrak dari aplikasi. Jangan menaruh kunci API provider di sana. Pada demo ini tidak ada API key. Adapter menolak endpoint di luar loopback dan host emulator Android.

Untuk emulator Android, host komputer biasanya diakses melalui `10.0.2.2`, bukan `127.0.0.1` perangkat emulator. Konfigurasi izin jaringan dan HTTP debug harus diperiksa tersendiri. Demonstrasi awal difokuskan pada web di komputer dosen, bukan APK produksi.

## 6. Jika browser menolak request

Bedakan error CORS, browser local-network permission, endpoint tidak aktif, dan model tidak tersedia. Periksa DevTools dan terminal Ollama. Jangan mematikan keamanan browser atau memakai `OLLAMA_ORIGINS=*` sebagai perbaikan umum.

Apabila perlu mengizinkan origin web yang digunakan, atur origin tepat berikut saat memulai Ollama pada perangkat model:

```bash
OLLAMA_HOST=127.0.0.1:11434 \
OLLAMA_ORIGINS=http://127.0.0.1:7080 \
OLLAMA_NO_CLOUD=1 ollama serve
```

Pada aplikasi desktop Ollama, konfigurasi environment dan restart mengikuti dokumentasi platform. Jangan menjalankan perintah server tambahan jika aplikasi sudah memakai port tersebut. Konfirmasi izin jaringan lokal di browser hanya untuk tujuan demo yang memang dipilih dosen.

## 7. Urutan demonstrasi saat mengajar

1. Simulator: kirim “Jelaskan state pada Flutter dengan analogi perpustakaan”. Ubah rincian pertanyaan. Tunjukkan bahwa simulator tetap memilih teks berdasarkan kata kunci.
2. Pilih Ollama dan kirim pertanyaan sama. Jelaskan bahwa respons kini dibentuk melalui inferensi model. Nilai kebenarannya tetap perlu diperiksa, bukan diasumsikan dari kelancaran bahasanya.
3. Tunjukkan `LayananAi.kirim()` masih mengembalikan `Stream<String>` dan `ViewModelObrolan` tidak diubah. Pada layanan nyata, event adalah potongan teks dari server, bukan selalu satu kata atau satu token.
4. Telusuri payload berisi system instruction dan satu pertanyaan. Riwayat pada UI tidak dikirim sebagai konteks. Pertanyaan lanjutan seperti “jelaskan yang tadi” belum memiliki konteks percakapan otomatis.
5. Tekan Hentikan di tengah jawaban. Pembatalan menutup konsumsi stream HTTP; ini bukan jaminan bahwa komputasi server langsung selesai. Periksa aktivitas Ollama bila ingin menilai perilaku server.
6. Hentikan server setelah demonstrasi normal selesai, kemudian kirim lagi. Bandingkan error jaringan dengan respons model yang keliru secara semantik.
7. Tampilkan test adapter yang memakai server tiruan. Jelaskan bahwa test deterministik membuktikan perilaku parser dan kontrak, bukan kualitas inferensi model.

## 8. Batas dan keamanan demo

- ViewModel tetap menjalankan penapis sebelum memanggil adapter. Penapis berbasis pola tidak mengenali seluruh data sensitif. Tetap gunakan pertanyaan contoh tanpa data pribadi atau kredensial.
- Mode model nyata belum menerapkan rate limit setara `PenjagaKuota` simulator. Demo bukan layanan multi-pengguna. Input dibatasi 4000 karakter, output dibatasi 192 token melalui opsi model dan 32000 karakter pada adapter, serta ada timeout 90 detik tanpa respons/event.
- Timeout diterapkan pada penantian koneksi dan jeda event, bukan batas waktu total seluruh stream. Jika stream terputus tanpa `done`, adapter melaporkan kegagalan dan UI mempertahankan hasil parsial.
- Jawaban dapat terpotong karena batas generasi. Model kecil dapat menghasilkan penjelasan atau kode yang salah. Periksa dokumentasi Flutter dan jalankan kode sebelum menjadikannya contoh yang dinilai.
- Riwayat hanya berada di memori layar. Tidak ada persistensi, RAG, tool execution, streaming reasoning, autentikasi server, atau audit produksi. Model tidak diberi kemampuan membaca file, menjalankan terminal, atau mengubah proyek.
- Jika kelak memakai provider awan berbayar, gunakan backend tepercaya dengan autentikasi, pembatasan biaya, serta penyimpanan kunci di server. Jangan menyalin pola endpoint lokal tanpa autentikasi menjadi layanan publik.

## 9. Verifikasi dan status

```bash
flutter analyze
flutter test
flutter build web -t lib/main_ai.dart
```

Test HTTP tiruan mencakup request, Unicode, penanda selesai, stream terputus, respons rusak, model tidak tersedia, endpoint nonlokal, dan penapisan sebelum HTTP. Lulusnya test bukan bukti koneksi ke model nyata. Inferensi end-to-end baru dinyatakan berhasil setelah curl dan aplikasi menerima respons dari Ollama yang benar-benar aktif.

## Referensi resmi

- API chat dan format respons: https://docs.ollama.com/api/chat
- Platform macOS yang didukung: https://docs.ollama.com/macos
- Loopback, origin web, local-only, dan tunnel/deployment: https://docs.ollama.com/faq
- Model contoh dan kebutuhan unduhan: https://ollama.com/library/qwen2.5:1.5b

Seluruh tambahan ini khusus folder dosen, tidak mengubah modul online, starter mahasiswa, maupun slide. Folder dosen tetap lokal dan tidak dipush.
