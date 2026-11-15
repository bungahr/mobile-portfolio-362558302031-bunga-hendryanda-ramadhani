import 'package:flutter/material.dart';

import 'screens/daftar_tugas_performa_screen.dart';

export 'data/sumber_tugas_contoh.dart';
export 'domain/filter_tugas.dart';
export 'domain/tugas_performa.dart';
export 'screens/daftar_tugas_performa_screen.dart';
export 'widgets/kartu_tugas_performa.dart';

class Modul11App extends StatelessWidget {
  const Modul11App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modul 11 — Optimasi Daftar Tugas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0E7490),
        useMaterial3: true,
      ),
      home: const LayarDaftarTugasPerforma(),
    );
  }
}
