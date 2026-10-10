import 'package:flutter/material.dart';
import 'package:modul_05_tugas_praktikum/modul_05/screens/task_list_screen.dart';
import 'package:modul_05_tugas_praktikum/modul_05/services/task_storage.dart';

const bool _lambat = bool.fromEnvironment('LAMBAT', defaultValue: false);

void main() {
  runApp(const Modul05App());
}

class Modul05App extends StatelessWidget {
  const Modul05App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Praktikum',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: TaskListScreen(
        storage: TaskStorage(
          tunda: _lambat ? const Duration(seconds: 2) : Duration.zero,
        ),
      ),
    );
  }
}
