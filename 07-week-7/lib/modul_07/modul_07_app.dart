import 'package:flutter/material.dart';

import 'data/repositori_tugas_memori.dart';
import 'data/sumber_tugas_memori.dart';
import 'domain/repositori_tugas.dart';
import 'presentation/view_model_daftar_tugas.dart';
import 'screens/daftar_tugas_screen.dart';

class Modul07App extends StatefulWidget {
  const Modul07App({super.key});

  @override
  State<Modul07App> createState() => _Modul07AppState();
}

class _Modul07AppState extends State<Modul07App> {
  late final SumberTugasMemori _sumber = SumberTugasMemori();

  late final RepositoriTugasMemori _repositoriKonkret = RepositoriTugasMemori(
    _sumber,
  );

  late final RepositoriTugas _repositori = _repositoriKonkret;

  late final ViewModelDaftarTugas _viewModel = ViewModelDaftarTugas(
    _repositori,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 07 — MVVM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: DaftarTugasScreen(viewModel: _viewModel),
    );
  }
}
