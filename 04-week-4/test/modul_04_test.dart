import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import 'package:week04/modul_04/screens/announcement_detail_screen.dart';
import 'package:week04/modul_04/screens/announcement_list_screen.dart';
import 'package:week04/modul_04/services/announcement_api.dart';
import 'package:week04/modul_04/widgets/announcement_card.dart';

void main() {
  List<Map<String, dynamic>> dataPosts(int jumlah) {
    return List<Map<String, dynamic>>.generate(
      jumlah,
      (int index) => <String, dynamic>{
        'id': index + 1,
        'title': 'Pengumuman ${index + 1}',
        'body': 'Isi pengumuman ${index + 1}',
      },
    );
  }

  testWidgets('Menampilkan loading lalu data', (WidgetTester tester) async {
    final AnnouncementApi api = AnnouncementApi(modeSimulasi: true);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    expect(find.text('Sedang memuat pengumuman...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(AnnouncementCard), findsWidgets);
  });

  testWidgets('Menampilkan error dari server', (WidgetTester tester) async {
    final MockClient client = MockClient((Request request) async {
      return Response('Server Error', 500);
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat pengumuman'), findsOneWidget);

    expect(find.textContaining('status 500'), findsOneWidget);

    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Filter kategori menampilkan keadaan kosong', (
    WidgetTester tester,
  ) async {
    final MockClient client = MockClient((Request request) async {
      return Response(
        jsonEncode(dataPosts(1)),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Beasiswa'));
    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada pengumuman untuk kategori Beasiswa.'),
      findsOneWidget,
    );
  });

  testWidgets('Menekan kartu membuka detail', (WidgetTester tester) async {
    final MockClient client = MockClient((Request request) async {
      return Response(
        jsonEncode(dataPosts(10)),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Pengumuman 1'));
    await tester.pumpAndSettle();

    expect(find.byType(AnnouncementDetailScreen), findsOneWidget);
  });

  testWidgets('Tombol refresh mengirim request baru', (
    WidgetTester tester,
  ) async {
    int jumlahRequest = 0;

    final MockClient client = MockClient((Request request) async {
      jumlahRequest++;

      return Response(
        jsonEncode(dataPosts(10)),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    await tester.pumpAndSettle();

    expect(jumlahRequest, 1);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(jumlahRequest, 2);
  });
}
