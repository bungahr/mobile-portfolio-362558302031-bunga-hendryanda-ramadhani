import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  const PapanDiagnostikPenyimpanan({super.key, required this.controller});

  final SesiController controller;

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _isi;
  bool _memuat = false;

  Future<void> _bacaPenyimpanan() async {
    setState(() {
      _memuat = true;
      _isi = null;
    });

    try {
      final hasil = await widget.controller.repository.intipMentah();

      if (!mounted) return;
      setState(() {
        _isi = hasil ?? 'Data mentah tidak tersedia.';
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isi = 'Gagal membaca penyimpanan: $e';
        _memuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.controller.repository;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostik Penyimpanan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Metode: ${repo.nama}'),
            Text(
              'Bertahan setelah restart: '
              '${repo.bertahanSetelahRestart ? 'Ya' : 'Tidak'}',
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _memuat ? null : _bacaPenyimpanan,
              child: const Text('Intip isi penyimpanan'),
            ),
            if (_memuat) const CircularProgressIndicator(),
            if (_isi != null) SelectableText(_isi!),
          ],
        ),
      ),
    );
  }
}
