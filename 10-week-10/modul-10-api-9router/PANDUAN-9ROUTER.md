# Panduan dosen Modul 10-API: 9router

## 1. Isi paket dan alur

Clone lokal ini terpisah dari modul_10_integrasi_ai. Cache build dan berkas environment rahasia tidak disalin. Nama paket Dart tetap dosen_modul_10 agar import dan test hasil clone konsisten. Folder asli tidak diubah.

Alur: Flutter memanggil proxy Node.js pada loopback. Proxy membaca API key dari environment dan memanggil Chat Completions 9router. Proxy mengubah SSE `choices[0].delta.content` menjadi NDJSON, lalu adapter Flutter menyediakan Stream<String> untuk ViewModel yang sama.

9router memakai antarmuka OpenAI-compatible. Konfigurasi ini tidak mengharuskan provider OpenAI langsung. Base URL dan ID model mengikuti instance serta provider yang Bapak atur di dashboard 9router. Endpoint yang dipakai adalah `[base URL]/chat/completions`, bukan Responses API.

## 2. Konfigurasi yang diisi dosen

Perlu Node.js 22+, Flutter/Dart yang sesuai proyek, dan layanan 9router yang sudah Bapak konfigurasi. Ollama dan unduhan model lokal tidak diperlukan untuk mode API.

Dari akar folder modul_10_api:

```bash
cp proxy/.env.example proxy/.env.local
```

Edit proxy/.env.local dengan editor lokal:

```dotenv
NINE_ROUTER_BASE_URL=http://127.0.0.1:20128/v1
NINE_ROUTER_API_KEY=ISI_KEY_9ROUTER_ANDA
NINE_ROUTER_MODEL=ISI_ID_MODEL_DARI_DASHBOARD
PROXY_PORT=8787
APP_ORIGIN=http://127.0.0.1:7081
```

- Base URL ini contoh instance lokal menurut dokumentasi 9router. Ganti jika instance Bapak berbeda. Untuk endpoint remote wajib HTTPS.
- Isi base URL sampai `/v1` jika instance Bapak memakai prefix tersebut. Jangan menambahkan `/chat/completions` lagi.
- Isi ID model lengkap yang tersedia di dashboard, termasuk prefix provider bila diperlukan. Tidak ada model default yang diasumsikan aktif.
- Key yang dimaksud adalah key endpoint 9router. Key/provider di dalam dashboard 9router diatur tersendiri.
- Jangan memasukkan key ke chat, source Dart, screenshot, atau dart-define. File .env.local diabaikan Git. Jangan membagikan seluruh folder ini kepada mahasiswa.

## 3. Menjalankan proxy

Terminal pertama, dari akar modul_10_api:

```bash
node --env-file=proxy/.env.local proxy/server.mjs
```

Tidak perlu npm install, karena proxy memakai modul bawaan Node.js. Cek:

```bash
curl http://127.0.0.1:8787/health
```

Hasil setelah konfigurasi lengkap: `{"ok":true,"configured":true}`. Ini hanya memeriksa kelengkapan konfigurasi, bukan keabsahan key/model. Jika kosong, health tetap tersedia tetapi chat ditolak. Proxy tidak mencetak prompt atau key.

## 4. Menjalankan Flutter

Terminal kedua, dari akar modul_10_api:

```bash
nix-shell ../shell.nix
flutter pub get
flutter run -d chrome \
  --web-hostname 127.0.0.1 --web-port 7081 \
  --dart-define=PROXY_URL=http://127.0.0.1:8787/chat
```

Entry point default sudah memakai main_api.dart. Untuk eksplisit tambahkan `-t lib/main_api.dart`. Mode awal simulator. Pilih **9router API / melalui proxy lokal** setelah proxy siap.

Port 7081 berbeda dari demo Ollama pada 7080. Jika port diubah, ubah APP_ORIGIN juga. Origin harus persis sama, termasuk hostname. Jangan mematikan keamanan browser atau menggunakan wildcard untuk mengatasi CORS. Perubahan dart-define memerlukan restart aplikasi. PROXY_URL bukan rahasia; API key tidak ditanam dalam aplikasi.

## 5. Demonstrasi mengajar

1. Jalankan simulator. Kirim dua pertanyaan berbeda yang memuat kata state. Tunjukkan respons yang tetap.
2. Pilih API dan kirim pertanyaan contoh yang sama. Jelaskan bahwa teks kini diteruskan ke 9router dan provider yang dikonfigurasi, yang dapat berada di luar komputer dosen.
3. Tunjukkan layanan_api.dart: Flutter hanya mengirim prompt ke proxy. Tunjukkan server.mjs: key, model, dan system instruction ditambahkan di server.
4. Telusuri SSE, NDJSON, dan Stream<String>. Potongan teks tidak selalu satu kata atau satu token.
5. Tekan Hentikan. Putusnya koneksi klien membatalkan request upstream pada proxy. Penghentian komputasi dan penagihan tetap mengikuti implementasi 9router/provider.
6. Periksa kebenaran respons dan jalankan kode yang disarankan model sebelum menggunakannya sebagai contoh yang dinilai.

## 6. Batas dan keamanan

- Demo hanya melayani satu permintaan aktif per proses proxy. Belum ada autentikasi pengguna atau pengelolaan multi-pengguna.
- Input maksimal 4000 karakter, body 20000 byte, output 32000 karakter, max_tokens 256, dan batas total 90 detik. Dukungan max_tokens bergantung provider/model. Ubah payload server jika model Bapak memerlukan parameter lain dan uji ulang.
- Riwayat hanya ditampilkan di UI, tidak dikirim sebagai konteks. Setiap prompt berdiri sendiri.
- Parser mengharapkan Chat Completions SSE dengan `[DONE]`. JSON non-streaming atau protokol lain ditolak. Respons parsial tidak dianggap selesai.
- Penapis ViewModel tetap digunakan, tetapi tidak mengenali seluruh data sensitif. Gunakan pertanyaan contoh tanpa data pribadi. Validasi server membatasi tipe dan panjang input, bukan seluruh risiko semantik.
- Proxy hanya bind ke 127.0.0.1, memeriksa Host dan origin tepat, serta tidak menerima key/model dari klien. Jangan mengeksposnya ke internet atau LAN publik.
- Untuk produksi perlu autentikasi, rate limit, pembatasan biaya, pengelolaan rahasia, serta kebijakan data. Penggunaan API dapat menghabiskan kuota atau biaya.
- Tidak ada request model nyata yang dijalankan otomatis pada penyiapan ini.

## 7. Troubleshooting

| Gejala | Pemeriksaan |
|---|---|
| Health configured false atau chat 503 | Isi key/model dan restart proxy |
| Proxy 403 | Hostname/port Flutter berbeda dari APP_ORIGIN atau Host tidak sesuai |
| Proxy 502 autentikasi | Periksa key 9router tanpa menampilkannya di UI/log |
| Proxy 502 umum | Periksa base URL, ID model, protokol streaming, dan provider di dashboard |
| Proxy 429 | Permintaan lain masih aktif atau batas upstream tercapai |
| Respons parsial lalu error | Upstream terputus, melewati batas, atau tidak mengirim DONE |
| Respons tampil sekaligus | Periksa streaming dan buffering pada provider, 9router, proxy, atau browser |

## 8. Verifikasi tanpa API key

```bash
node --test proxy/server.test.mjs
flutter analyze
flutter test
flutter build web -t lib/main_api.dart
```

Test memakai HTTP/SSE tiruan dan tidak menghubungi provider. Koneksi nyata baru dapat dibuktikan setelah Bapak mengisi konfigurasi dan menerima respons provider.

Entry point hasil clone tetap tersedia: main_starter.dart, main_kunci.dart, dan main_ai.dart. Seluruh folder khusus dosen dan tidak dipush.

## Referensi resmi proyek 9router

https://github.com/decolua/9router/blob/master/gitbook/content/en/integration/other-tools.md
