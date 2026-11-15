import 'package:flutter/material.dart';

import '../domain/tugas_performa.dart';

class KartuTugasPerforma extends StatelessWidget {
  final TugasPerforma tugas;

  const KartuTugasPerforma({super.key, required this.tugas});

  @override
  Widget build(BuildContext context) {
    final selesai = tugas.status == StatusTugas.selesai;

    return Card(
      key: key ?? ValueKey('task-card-${tugas.nomor}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: selesai
              ? Colors.green.shade100
              : Colors.blue.shade100,
          child: Text(
            tugas.nomor.toString().padLeft(4, '0'),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        title: Text(
          tugas.judul,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(tugas.mataKuliah),
        trailing: Chip(
          label: Text(selesai ? 'Selesai' : 'Aktif'),
          backgroundColor: selesai
              ? Colors.green.shade100
              : Colors.orange.shade100,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
