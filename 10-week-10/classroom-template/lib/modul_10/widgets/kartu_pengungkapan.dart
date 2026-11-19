import 'package:flutter/material.dart';

/// Kartu pengungkapan (*disclosure*) bahwa jawaban dihasilkan oleh AI.
///
/// Bagian dari tanggung jawab penggunaan AI: pengguna berhak tahu bahwa teks
/// yang dibacanya bukan tulisan manusia dan bahwa keluarannya dapat keliru.
/// Kartu ini selalu tampil, sehingga aplikasi tidak dapat dipakai tanpa
/// pengguna pernah melihat batasnya.
class KartuPengungkapan extends StatelessWidget {
  const KartuPengungkapan({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: skema.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 18,
            color: skema.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Jawaban dihasilkan oleh model AI dan dapat keliru. '
              'Jangan kirimkan data pribadi, kredensial, atau kode rahasia. '
              'Verifikasi setiap jawaban sebelum dipakai.',
              style: TextStyle(
                color: skema.onTertiaryContainer,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
