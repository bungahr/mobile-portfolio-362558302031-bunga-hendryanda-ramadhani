import 'package:flutter/material.dart';

import 'controllers/sesi_controller.dart';
import 'repositories/aman_sesi_repository.dart';
import 'repositories/memori_sesi_repository.dart';
import 'repositories/prefs_sesi_repository.dart';
import 'repositories/sesi_repository.dart';
import 'widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({super.key});

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late SesiRepository _repository;
  late SesiController _controller;

  @override
  void initState() {
    super.initState();
    _repository = MemoriSesiRepository();
    _controller = SesiController(repository: _repository);
    _controller.pulihkanSesi();
  }

  void _gantiRepository(String? pilihan) {
    if (pilihan == null || pilihan == _repository.nama) return;

    _controller.dispose();

    switch (pilihan) {
      case 'SharedPreferences':
        _repository = PrefsSesiRepository();
        break;
      case 'Secure Storage':
        _repository = AmanSesiRepository();
        break;
      default:
        _repository = MemoriSesiRepository();
    }

    _controller = SesiController(repository: _repository);
    _controller.pulihkanSesi();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pengayaan Modul 06',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mode penyimpanan sesi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _repository.nama,
                      items: const [
                        DropdownMenuItem(
                          value: 'Memori',
                          child: Text('Memori'),
                        ),
                        DropdownMenuItem(
                          value: 'SharedPreferences',
                          child: Text('Prefs'),
                        ),
                        DropdownMenuItem(
                          value: 'Secure Storage',
                          child: Text('Aman'),
                        ),
                      ],
                      onChanged: _gantiRepository,
                    ),
                  ],
                ),
              ),
              Expanded(child: GerbangSesi(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}
