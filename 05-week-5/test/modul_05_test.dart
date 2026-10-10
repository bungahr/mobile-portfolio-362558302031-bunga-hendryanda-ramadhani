import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modul_05_tugas_praktikum/modul_05/models/task.dart';
import 'package:modul_05_tugas_praktikum/modul_05/screens/task_list_screen.dart';
import 'package:modul_05_tugas_praktikum/modul_05/services/task_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Task bisa diubah ke JSON dan dibaca kembali', () {
    const Task awal = Task(
      id: 'uji-1',
      title: 'Laporan praktikum',
      course: 'Pemrograman Perangkat Bergerak',
      createdAt: '2026-09-15',
      done: true,
      prioritas: 1,
    );

    final Task hasil = Task.fromJson(awal.toJson());
    expect(hasil.id, awal.id);
    expect(hasil.title, awal.title);
    expect(hasil.course, awal.course);
    expect(hasil.done, isTrue);
    expect(hasil.prioritas, 1);
  });

  test('Tugas yang disimpan dapat dibaca kembali', () async {
    const TaskStorage storage = TaskStorage();
    const Task tugas = Task(
      id: 'uji-2',
      title: 'Menguji penyimpanan',
      course: 'Pemrograman Perangkat Bergerak',
      createdAt: '2026-09-16',
      done: true,
      prioritas: 2,
    );

    await storage.simpan(<Task>[tugas]);
    final List<Task> hasil = await storage.muat();

    expect(hasil.length, 1);
    expect(hasil.single.id, 'uji-2');
    expect(hasil.single.done, isTrue);
  });

  test('Data JSON rusak menghasilkan FormatException', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TaskStorage.kunciTugas, '{bukan json');

    const TaskStorage storage = TaskStorage();
    await expectLater(storage.muat(), throwsA(isA<FormatException>()));
  });

  testWidgets('Daftar kosong menampilkan empty state', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TaskStorage.kunciTugas, '[]');

    await tester.pumpWidget(
      const MaterialApp(home: TaskListScreen(storage: TaskStorage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada tugas'), findsOneWidget);
  });

  test('latihan 4 mencadangkan JSON rusak', () async {
    const String dataRusak = '{ini sengaja bukan JSON yang sah';

    SharedPreferences.setMockInitialValues(<String, Object>{
      TaskStorage.kunciTugas: dataRusak,
    });

    TaskStorage.pesanPemulihan = null;

    const TaskStorage storage = TaskStorage();

    final List<Task> hasil = await storage.muat(pulihkanJsonRusak: true);

    expect(hasil, isEmpty);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    expect(prefs.getString(TaskStorage.kunciCadangan), dataRusak);

    expect(prefs.getString(TaskStorage.kunciTugas), '[]');

    expect(TaskStorage.pesanPemulihan, contains('dicadangkan'));
  });
}
