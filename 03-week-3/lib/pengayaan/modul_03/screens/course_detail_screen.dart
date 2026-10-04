import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../krs_provider.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseCode});

  final String courseCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(krsProvider.notifier).cariMataKuliah(courseCode);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Mata kuliah tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(course.code)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(course.lecturer),
            const SizedBox(height: 8),
            Text('${course.sks} SKS'),
            const SizedBox(height: 24),
            Text(
              course.description.isNotEmpty
                  ? course.description
                  : 'Belum ada deskripsi.',
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
