import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';
import '../screens/beranda_pengayaan_screen.dart';
import '../screens/login_pengayaan_screen.dart';
import '../screens/profil_pengayaan_screen.dart';

class GerbangSesi extends StatelessWidget {
  const GerbangSesi({
    super.key,
    required this.controller,
    this.halamanProfil = false,
  });

  final SesiController controller;
  final bool halamanProfil;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.status) {
          case StatusSesi.memeriksa:
          case StatusSesi.memproses:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case StatusSesi.masuk:
            if (halamanProfil) {
              return ProfilPengayaanScreen(controller: controller);
            }

            return BerandaPengayaanScreen(
              controller: controller,
              onBukaProfil: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GerbangSesi(
                      controller: controller,
                      halamanProfil: true,
                    ),
                  ),
                );
              },
            );

          case StatusSesi.keluar:
          case StatusSesi.gagal:
          case StatusSesi.kedaluwarsa:
            return LoginPengayaanScreen(controller: controller);
        }
      },
    );
  }
}
