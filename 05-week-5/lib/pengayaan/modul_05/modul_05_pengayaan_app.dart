import 'dart:async';

import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'repositories/prefs_task_repository.dart';
import 'repositories/sqlite_task_repository.dart';
import 'repositories/task_repository.dart';
import 'screens/task_list_pengayaan_screen.dart';

void main() {
  runApp(const Modul05PengayaanApp());
}

class Modul05PengayaanApp extends StatefulWidget {
  const Modul05PengayaanApp({super.key});

  @override
  State<Modul05PengayaanApp> createState() => _Modul05PengayaanAppState();
}

class _Modul05PengayaanAppState extends State<Modul05PengayaanApp> {
  SumberDataTugas _sumber = SumberDataTugas.sharedPreferences;

  late final AppDatabase _basisData = AppDatabase();
  late final TaskRepository _repoPrefs = PrefsTaskRepository();
  late final TaskRepository _repoSqlite = SqliteTaskRepository(
    basisData: _basisData,
  );

  TaskRepository get _repoAktif {
    switch (_sumber) {
      case SumberDataTugas.sharedPreferences:
        return _repoPrefs;
      case SumberDataTugas.sqlite:
        return _repoSqlite;
    }
  }

  void _gantiSumber(SumberDataTugas sumber) {
    if (sumber == _sumber) return;
    setState(() => _sumber = sumber);
  }

  @override
  void dispose() {
    unawaited(_basisData.tutup());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Praktikum Pengayaan',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: TaskListPengayaanScreen(
        key: ValueKey<SumberDataTugas>(_sumber),
        repository: _repoAktif,
        sumber: _sumber,
        onGantiSumber: _gantiSumber,
      ),
    );
  }
}
