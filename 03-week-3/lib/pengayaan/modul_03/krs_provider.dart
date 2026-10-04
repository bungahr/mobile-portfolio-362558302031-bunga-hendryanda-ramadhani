import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modul_03/models/krs_course.dart';

class KrsNotifier extends Notifier<List<KrsCourse>> {
  @override
  List<KrsCourse> build() => KrsCourse.getInitialCourses();

  int get totalSks => state.fold(0, (sum, course) => sum + course.sks);

  bool tambahMataKuliah(KrsCourse course) {
    final bool exists = state.any(
      (c) => c.code.toUpperCase() == course.code.toUpperCase(),
    );

    if (exists) {
      return false;
    }

    if (totalSks + course.sks > 24) {
      return false;
    }

    state = [...state, course];
    return true;
  }

  void hapusMataKuliah(String code) {
    state = state.where((c) => c.code != code).toList();
  }

  KrsCourse? cariMataKuliah(String code) {
    for (final course in state) {
      if (course.code.toUpperCase() == code.toUpperCase()) {
        return course;
      }
    }

    return null;
  }
}

final krsProvider = NotifierProvider<KrsNotifier, List<KrsCourse>>(
  KrsNotifier.new,
);

final totalSksProvider = Provider<int>((ref) {
  final courses = ref.watch(krsProvider);

  return courses.fold(0, (sum, course) => sum + course.sks);
});
