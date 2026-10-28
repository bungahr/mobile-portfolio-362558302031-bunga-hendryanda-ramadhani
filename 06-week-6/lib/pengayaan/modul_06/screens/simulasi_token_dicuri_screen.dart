import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';

class SimulasiTokenDicuriScreen extends StatelessWidget {
  const SimulasiTokenDicuriScreen({super.key, required this.controller});

  final SesiController controller;

  @override
  Widget build(BuildContext context) {
    final sesi = controller.sesi;
    final tokenAda = sesi != null && sesi.token.isNotEmpty;
    final sesiAktif = sesi != null && !sesi.sudahKedaluwarsa(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Token Dicuri')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.security, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Simulasi risiko penyalahgunaan token',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Token tersedia: ${tokenAda ? "Ya" : "Tidak"}'),
                  const SizedBox(height: 8),
                  Text('Sesi masih berlaku: ${sesiAktif ? "Ya" : "Tidak"}'),
                  const SizedBox(height: 8),
                  Text('Repository: ${controller.repository.nama}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jika seseorang berhasil memperoleh token yang masih berlaku, '
            'orang tersebut berpotensi menyalahgunakannya. Penyimpanan aman '
            'mengurangi risiko token terbaca dari penyimpanan lokal, tetapi '
            'tidak menjamin token kebal dari pencurian pada perangkat yang '
            'sudah disusupi.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Kesimpulan: token tetap perlu dilindungi meskipun memakai '
            'secure storage. Aplikasi juga perlu membatasi masa berlaku '
            'token dan menyediakan mekanisme pencabutan atau pembaruan sesi.',
          ),
        ],
      ),
    );
  }
}
