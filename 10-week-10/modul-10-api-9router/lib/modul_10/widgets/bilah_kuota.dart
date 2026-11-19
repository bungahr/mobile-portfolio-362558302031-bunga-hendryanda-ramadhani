import 'package:flutter/material.dart';

/// Menampilkan sisa kuota permintaan pada panel diagnostik.
///
/// Angka ini berasal dari [PenjagaKuota] yang sama dengan yang dipakai layanan,
/// sehingga apa yang dilihat pengguna benar-benar keadaan yang membatasi
/// pengiriman, bukan sekadar hiasan.
class BilahKuota extends StatelessWidget {
  const BilahKuota({super.key, required this.sisa, required this.batas});

  /// Sisa permintaan yang masih diizinkan.
  final int sisa;

  /// Batas permintaan per jendela waktu.
  final int batas;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    final double rasio = batas == 0 ? 0.0 : sisa / batas;

    return Row(
      children: <Widget>[
        Icon(Icons.speed, size: 16, color: skema.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          'Sisa kuota: $sisa/$batas',
          style: TextStyle(color: skema.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: rasio, minHeight: 6),
          ),
        ),
      ],
    );
  }
}
