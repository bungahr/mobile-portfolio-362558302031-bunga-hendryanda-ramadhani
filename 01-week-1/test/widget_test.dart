import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';
import 'package:my_first_app/modul_01/profile_screen.dart';

void main() {
  testWidgets('Profile screen tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const PoliwangiProfileApp());

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
