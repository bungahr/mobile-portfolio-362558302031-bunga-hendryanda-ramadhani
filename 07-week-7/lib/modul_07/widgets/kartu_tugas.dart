import 'package:flutter/material.dart';

import '../domain/tugas.dart';

class KartuTugas extends StatelessWidget {
  const KartuTugas({
    super.key,
    required this.tugas,
    required this.onUbahStatus,
    required this.onHapus,
    this.sedangSibuk = false,
  });

  final Tugas tugas;

  final VoidCallback onUbahStatus;

  final VoidCallback onHapus;

  final bool sedangSibuk;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    final TextTheme teks = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            Checkbox(
              value: tugas.selesai,
              onChanged: sedangSibuk ? null : (_) => onUbahStatus(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    tugas.judul,
                    style: teks.titleSmall?.copyWith(
                      decoration: tugas.selesai
                          ? TextDecoration.lineThrough
                          : null,
                      color: tugas.selesai ? skema.outline : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      _LencanaPrioritas(prioritas: tugas.prioritas),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tugas.mataKuliah,
                          style: teks.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus tugas',
              icon: const Icon(Icons.delete_outline),
              onPressed: sedangSibuk ? null : onHapus,
            ),
          ],
        ),
      ),
    );
  }
}

class _LencanaPrioritas extends StatelessWidget {
  const _LencanaPrioritas({required this.prioritas});

  final int prioritas;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    final (Color latar, Color depan) = switch (prioritas) {
      1 => (skema.errorContainer, skema.onErrorContainer),
      3 => (skema.surfaceContainerHighest, skema.onSurfaceVariant),
      _ => (skema.primaryContainer, skema.onPrimaryContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        Tugas.labelPrioritas(prioritas),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: depan, fontWeight: FontWeight.w600),
      ),
    );
  }
}
