import 'package:flutter/material.dart';

import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.tampilkanToken = false,
  });

  final SesiPengguna sesi;
  final DateTime sekarang;
  final VoidCallback? onKeluar;
  final bool sedangKeluar;
  final bool tampilkanToken;

  String get _tokenTersamar {
    if (sesi.token.isEmpty) return '(kosong)';
    if (sesi.token.length <= 6) return '******';
    return '${sesi.token.substring(0, 6)}${'*' * 12}';
  }

  String formatWaktu(DateTime waktu) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final tanggal = waktu.day.toString().padLeft(2, '0');
    final jam = waktu.hour.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');

    return '$tanggal ${bulan[waktu.month - 1]} ${waktu.year}, $jam:$menit';
  }

  String formatSisa(Duration durasi) {
    if (durasi.isNegative || durasi == Duration.zero) {
      return 'Kedaluwarsa';
    }

    final jam = durasi.inHours;
    final menit = durasi.inMinutes.remainder(60);
    final detik = durasi.inSeconds.remainder(60);

    if (jam > 0) return '$jam jam $menit menit';
    if (menit > 0) return '$menit menit $detik detik';
    return '$detik detik';
  }

  @override
  Widget build(BuildContext context) {
    final waktuMasuk = DateTime.tryParse(sesi.masukPada);
    final sisa = sesi.sisaWaktu(sekarang);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sesi pengguna aktif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _BarisInfo(label: 'Nama', nilai: sesi.nama),
            _BarisInfo(label: 'Email', nilai: sesi.email),
            _BarisInfo(
              label: 'Peran',
              nilai: SesiPengguna.labelPeran(sesi.peran),
            ),
            _BarisInfo(
              label: 'Masuk pada',
              nilai: waktuMasuk == null
                  ? sesi.masukPada
                  : formatWaktu(waktuMasuk),
            ),
            _BarisInfo(
              label: 'Sisa sesi',
              nilai: formatSisa(sisa),
              warna: sisa < const Duration(minutes: 5) ? Colors.red : null,
            ),
            _BarisInfo(
              label: 'Token',
              nilai: tampilkanToken ? sesi.token : _tokenTersamar,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: sedangKeluar ? null : onKeluar,
                icon: sedangKeluar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(sedangKeluar ? 'Keluar...' : 'Keluar dari akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.label, required this.nilai, this.warna});

  final String label;
  final String nilai;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(nilai, style: TextStyle(color: warna)),
          ),
        ],
      ),
    );
  }
}
