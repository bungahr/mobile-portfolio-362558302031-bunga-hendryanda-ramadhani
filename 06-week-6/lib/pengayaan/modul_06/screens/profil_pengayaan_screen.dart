import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';

class ProfilPengayaanScreen extends StatelessWidget {
  const ProfilPengayaanScreen({super.key, required this.controller});

  final SesiController controller;

  @override
  Widget build(BuildContext context) {
    final sesi = controller.sesi;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              const Icon(Icons.account_circle_outlined, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Profil hanya dapat dibuka saat sesi aktif.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('Email: ${sesi?.email ?? '-'}'),
              const SizedBox(height: 12),
              Text('Nama: ${sesi?.nama ?? '-'}'),
              const SizedBox(height: 12),
              Text('Peran: ${sesi?.peran ?? '-'}'),
            ],
          ),
        ),
      ),
    );
  }
}
