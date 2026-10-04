import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

class Modul03PengayaanApp extends StatelessWidget {
  const Modul03PengayaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Modul 03 — Fase B',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
          useMaterial3: true,
        ),
        routerConfig: modul03Router,
      ),
    );
  }
}
