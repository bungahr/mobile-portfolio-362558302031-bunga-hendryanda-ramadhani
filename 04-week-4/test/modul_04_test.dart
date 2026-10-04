import 'dart:async';
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

  test('Latihan 1 - TimeoutException ditangani', () async {
    final MockClient client = MockClient((Request request) async {
      await Future<void>.delayed(const Duration(seconds: 2));

      return Response('[]', 200);
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await expectLater(
      api.ambilPengumuman(),
      throwsA(
        predicate<Object>(
          (Object error) => error.toString().contains('timeout'),
        ),
      ),
    );

    api.tutup();
  });

  test('Latihan 1 - ClientException ditangani', () async {
    final MockClient client = MockClient((Request request) async {
      throw ClientException('Koneksi gagal');
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await expectLater(
      api.ambilPengumuman(),
      throwsA(
        predicate<Object>(
          (Object error) =>
              error.toString().contains('Gagal terhubung ke server'),
        ),
      ),
    );

    api.tutup();
  });

  testWidgets('Latihan 2 - penghitung percobaan bertambah', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('Portal Pengumuman TRPL (0)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));

    await tester.pumpAndSettle();

    expect(find.text('Portal Pengumuman TRPL (1)'), findsOneWidget);
  });

  testWidgets('Latihan 3 - pencarian judul tidak mengirim request baru', (
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

    final Finder searchField = find.byType(TextField);

    await tester.enterText(searchField, 'Pengumuman 9');

    await tester.pump();

    expect(jumlahRequest, 1);

    expect(find.byType(AnnouncementCard), findsOneWidget);

    expect(find.text('Pengumuman 8'), findsNothing);
  });

  testWidgets('Latihan 4 - refresh tetap menampilkan daftar', (
    WidgetTester tester,
  ) async {
    final Completer<Response> completer = Completer<Response>();

    int jumlahRequest = 0;

    final MockClient client = MockClient((Request request) async {
      jumlahRequest++;

      if (jumlahRequest == 1) {
        return Response(
          jsonEncode(dataPosts(10)),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }

      return completer.future;
    });

    final AnnouncementApi api = AnnouncementApi(client: client);

    await tester.pumpWidget(
      MaterialApp(home: AnnouncementListScreen(api: api)),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.refresh));

    await tester.pump();

    expect(find.byType(AnnouncementCard), findsWidgets);

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    completer.complete(
      Response(
        jsonEncode(dataPosts(10)),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      ),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('Latihan 5 - detail menerima jumlah kategori', (
    WidgetTester tester,
  ) async {
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

    expect(
      find.textContaining('pengumuman berada di kategori'),
      findsOneWidget,
    );
  });
}
