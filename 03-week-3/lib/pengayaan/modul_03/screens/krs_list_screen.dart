import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../krs_provider.dart';
import '../../../modul_03/models/krs_course.dart';

class KrsListScreen extends ConsumerWidget {
  const KrsListScreen({super.key});

  Future<void> _konfirmasiHapus(
    BuildContext context,
    WidgetRef ref,
    KrsCourse course,
  ) async {
    final bool? dikonfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus mata kuliah?'),
        content: Text('Yakin ingin menghapus "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!context.mounted || dikonfirmasi != true) {
      return;
    }

    ref.read(krsProvider.notifier).hapusMataKuliah(course.code);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<KrsCourse> courses = ref.watch(krsProvider);
    final int totalSks = ref.watch(totalSksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rencana Studi — Fase B')),
      body: courses.isEmpty
          ? const Center(child: Text('Belum ada mata kuliah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final KrsCourse course = courses[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${course.sks}')),
                    title: Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${course.code} • ${course.lecturer}'),
                    onTap: () {
                      context.push('/modul-03/detail/${course.code}');
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _konfirmasiHapus(context, ref, course),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/modul-03/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah MK'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total SKS: $totalSks / 24',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
