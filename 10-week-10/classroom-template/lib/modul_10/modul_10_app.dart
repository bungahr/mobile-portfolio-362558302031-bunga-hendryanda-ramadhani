import 'package:flutter/material.dart';

import 'screens/layar_obrolan_ai.dart';

/// Titik masuk Modul 10 — AI Feature Integration.
///
/// Berbeda dari modul sebelumnya, tidak ada lapisan penyedia global di sini.
/// Ketergantungan dirakit langsung di dalam layar, karena hanya satu layar yang
/// memakainya. Aturan yang dipakai sederhana: tambahkan perakitan terpusat
/// hanya ketika jumlah pemakainya sudah lebih dari satu.
class Modul10App extends StatelessWidget {
  const Modul10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modul 10 — AI Feature Integration',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0284C7),
        useMaterial3: true,
      ),
      home: const LayarObrolanAi(),
    );
  }
}
