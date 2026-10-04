import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/announcement_list_screen.dart';

class Modul04PengayaanApp extends StatelessWidget {
  const Modul04PengayaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Modul 04 Pengayaan — Dio & Riverpod',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
          useMaterial3: true,
        ),
        home: const AnnouncementListScreen(),
      ),
    );
  }
}
