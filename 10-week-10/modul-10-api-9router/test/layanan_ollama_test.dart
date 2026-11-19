import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dosen_modul_10/ai_nyata/layanan_ollama.dart';
import 'package:dosen_modul_10/modul_10/presentation/view_model_obrolan.dart';

void main() {
  LayananOllama fake(String body, {int status = 200}) => LayananOllama(
    buatClient: () => MockClient((_) async => http.Response(body, status)),
  );
  test('mengirim kontrak chat dan mempertahankan potongan Unicode', () async {
    final layanan = LayananOllama(
      buatClient:
          () => MockClient((request) async {
            final body = jsonDecode(request.body);
            expect(body['stream'], true);
            expect(body['messages'].last['content'], 'Halo');
            return http.Response(
              '{"message":{"content":"Hai "},"done":false}\n'
              '{"message":{"content":"dosen ☀"},"done":true}\n',
              200,
              headers: {'content-type': 'application/x-ndjson; charset=utf-8'},
            );
          }),
    );
    expect(await layanan.kirim('Halo').toList(), ['Hai ', 'dosen ☀']);
    layanan.tutup();
    layanan.tutup();
    await expectLater(layanan.kirim('lagi'), emitsError(isA<GalatModel>()));
  });
  test('stream terputus tidak dianggap sukses', () async {
    await expectLater(
      fake('{"message":{"content":"parsial"},"done":false}\n').kirim('x'),
      emitsInOrder(['parsial', emitsError(isA<GalatModel>())]),
    );
  });
  test('model tidak tersedia menghasilkan pesan konfigurasi', () async {
    await expectLater(
      fake('{}', status: 404).kirim('x'),
      emitsError(isA<GalatModel>()),
    );
  });
  test('JSON rusak, error server, dan hasil kosong ditolak', () async {
    for (final body in [
      'bukan json\n',
      '{"error":"oops"}\n',
      '{"done":true}\n',
    ]) {
      await expectLater(fake(body).kirim('x'), emitsError(isA<GalatModel>()));
    }
  });
  test('endpoint nonlokal ditolak sebelum koneksi', () {
    expect(
      () => LayananOllama(endpoint: 'https://example.com/api/chat'),
      throwsArgumentError,
    );
  });
  test('ViewModel menolak pola kunci sebelum memanggil HTTP', () async {
    var calls = 0;
    final model = ViewModelObrolan(
      layanan: LayananOllama(
        buatClient: () {
          calls++;
          return MockClient((_) async => http.Response('', 200));
        },
      ),
    );
    await model.kirim('contoh sk-abcdefghijklmnop');
    expect(calls, 0);
    model.dispose();
  });
}
