import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';
import 'simulasi_token_dicuri_screen.dart';

class BerandaPengayaanScreen extends StatelessWidget {
  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.onBukaProfil,
  });

  final SesiController controller;
  final VoidCallback onBukaProfil;

  @override
  Widget build(BuildContext context) {
    final sesi = controller.sesi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Pengayaan'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 64,
            color: Colors.teal,
          ),
          const SizedBox(height: 12),
          Text(
            'Login berhasil!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Repository: ${controller.repository.nama}'),
                  const SizedBox(height: 8),
                  Text('Email: ${sesi?.email ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Peran: ${SesiPengguna.labelPeran}'),
                  const SizedBox(height: 8),
                  Text('Masuk pada: ${sesi?.masukPada ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Kedaluwarsa pada: ${sesi?.kedaluwarsaPada ?? '-'}'),
                  const SizedBox(height: 8),
                  Text(controller.repository.keterangan),
                ],
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onBukaProfil,
            icon: const Icon(Icons.person_outline),
            label: const Text('Buka Profil'),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: controller.perbaruiSesi,
            icon: const Icon(Icons.refresh),
            label: const Text('Perbarui sesi'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      SimulasiTokenDicuriScreen(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.security),
            label: const Text('Simulasi Token Dicuri'),
          ),
          const SizedBox(height: 20),
          PapanDiagnostikPenyimpanan(controller: controller),
        ],
      ),
    );
  }
}
