import 'package:flutter/material.dart';
import 'modul_02/study_kasus/ruang_praktikum.dart';

void main() {
  runApp(const Modul02DosenApp());
}

class Modul02DosenApp extends StatelessWidget {
  const Modul02DosenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 02 Dashboard Akademik',
      // home: AcademicDashboardScreen(),
      home: RuangPraktikum(),
    );
  }
}