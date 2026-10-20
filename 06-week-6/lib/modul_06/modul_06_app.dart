import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/auth_api.dart';
import 'services/sesi_memori.dart';

class Modul06App extends StatelessWidget {
  const Modul06App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication & Session Security',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      home: LoginScreen(api: AuthApi(), sesiMemori: SesiMemori()),
    );
  }
}
