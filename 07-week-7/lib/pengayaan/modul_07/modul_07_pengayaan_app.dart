import 'package:flutter/material.dart';

import '../../modul_07/domain/repositori_tugas.dart';
import 'core/lokator.dart';
import 'presentation/view_model_tugas_pengayaan.dart';
import 'screens/daftar_tugas_pengayaan_screen.dart';

class Modul07PengayaanApp extends StatefulWidget {
  const Modul07PengayaanApp({super.key, this.repositori});

  final RepositoriTugas? repositori;

  @override
  State<Modul07PengayaanApp> createState() => _Modul07PengayaanAppState();
}

class _Modul07PengayaanAppState extends State<Modul07PengayaanApp> {
  ViewModelTugasPengayaan? _viewModel;

  bool _gagalSiap = false;

  @override
  void initState() {
    super.initState();
    _siapkan();
  }

  Future<void> _siapkan() async {
    try {
      await siapkanLokator(repositori: widget.repositori);
      if (!mounted) return;
      setState(() {
        _viewModel = lokator<ViewModelTugasPengayaan>();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _gagalSiap = true);
    }
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 07 Fase B — DI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: _bangunBeranda(),
    );
  }

  Widget _bangunBeranda() {
    if (_gagalSiap) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modul 07 Fase B')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Service locator gagal dirakit. Periksa siapkanLokator().',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final ViewModelTugasPengayaan? vm = _viewModel;
    if (vm == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DaftarTugasPengayaanScreen(viewModel: vm);
  }
}
