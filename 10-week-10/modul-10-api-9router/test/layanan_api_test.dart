import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dosen_modul_10/ai_nyata/layanan_api.dart';

void main() {
  test('mengirim prompt tanpa kredensial dan menerima NDJSON proxy', () async {
    final api = LayananApi(
      buatClient:
          () => MockClient((r) async {
            expect(r.url.path, '/chat');
            expect(r.headers.containsKey('Authorization'), false);
            expect(r.body, '{"prompt":"Halo"}');
            return http.Response(
              '{"text":"Halo "}\n{"text":"dosen"}\n{"done":true}\n',
              200,
            );
          }),
    );
    expect(await api.kirim('Halo').toList(), ['Halo ', 'dosen']);
    api.tutup();
  });
  test(
    'stream proxy terputus menghasilkan error setelah teks parsial',
    () async {
      final api = LayananApi(
        buatClient:
            () => MockClient(
              (_) async => http.Response('{"text":"parsial"}\n', 200),
            ),
      );
      await expectLater(
        api.kirim('x'),
        emitsInOrder(['parsial', emitsError(isA<GalatModel>())]),
      );
    },
  );
  test('proxy belum dikonfigurasi tidak dianggap jawaban model', () async {
    final api = LayananApi(
      buatClient:
          () => MockClient(
            (_) async => http.Response('{"error":"belum diatur"}', 503),
          ),
    );
    await expectLater(api.kirim('x'), emitsError(isA<GalatModel>()));
  });
}
