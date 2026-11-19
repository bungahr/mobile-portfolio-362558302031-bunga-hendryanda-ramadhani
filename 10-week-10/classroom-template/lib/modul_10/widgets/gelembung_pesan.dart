import 'package:flutter/material.dart';

import '../domain/pesan_ai.dart';

/// Balon pesan untuk satu [PesanAi].
///
/// Widget ini murni tampilan: ia tidak menyimpan data, tidak memanggil layanan,
/// dan tidak mengetahui dari mana pesannya berasal. Karena itu ia dapat diuji
/// dengan satu kali `pumpWidget`.
class GelembungPesan extends StatelessWidget {
  const GelembungPesan({super.key, required this.pesan});

  /// Pesan yang ditampilkan.
  final PesanAi pesan;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    final bool dariPengguna = pesan.dariPengguna;

    return Align(
      alignment: dariPengguna ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: dariPengguna
              ? skema.primaryContainer
              : skema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          pesan.kosong ? '…' : pesan.isi,
          style: TextStyle(
            color: dariPengguna
                ? skema.onPrimaryContainer
                : skema.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
