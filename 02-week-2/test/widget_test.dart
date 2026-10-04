import 'package:flutter_test/flutter_test.dart';

import '../lib/modul_02/academic_dashboard_screen.dart';

void main() {
  testWidgets('Academic Dashboard tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const AcademicDashboardScreen());

    expect(find.text('Dashboard Akademik TRPL'), findsOneWidget);
    expect(find.text('Mata Kuliah Semester 5'), findsOneWidget);
  });
}
