# Hasil Percobaan Pengayaan Modul 10

## 1. Batas kuota

| Percobaan | Masukan | Hasil | Alasan |
|---|---|---|---|
| 1–5 | Lima pertanyaan berbeda dalam satu menit | Diterima | Masih dalam batas lima permintaan |
| 6 | Pertanyaan keenam sebelum satu menit berakhir | Ditolak | Kuota lima permintaan telah habis |

## 2. Penyaring pesan

| Masukan | Hasil | Alasan |
|---|---|---|
| Kunci API tiruan: `sk-abcdefghijklmnop123456` | Ditolak | Terdeteksi pola yang menyerupai kunci API |
| `bunga@example.com` | Disamarkan menjadi `[surel disamarkan]` | Melindungi alamat email |
| `Apa fungsi widget pada Flutter?` | Diizinkan | Tidak mengandung pola data sensitif yang dikenali |

## 3. Kesimpulan

Pengujian menunjukkan bahwa layanan lokal membatasi permintaan maksimal lima kali dalam satu menit. Penyaring juga menolak teks yang menyerupai kunci API, menyamarkan alamat email, dan tetap mengizinkan pertanyaan biasa. Penyaring ini berbasis pola sehingga belum dapat menjamin semua bentuk data sensitif terdeteksi.
