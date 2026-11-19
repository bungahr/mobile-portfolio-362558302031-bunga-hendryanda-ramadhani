import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modul_10/domain/galat_ai.dart';
import '../modul_10/domain/kontrak_layanan_ai.dart';

class GalatModel extends GalatAi {
  const GalatModel(this.pesan, [SebabGalat sebab = SebabGalat.tidakDiketahui])
    : super(sebab);
  final String pesan;
  @override
  String get pesanPengguna => pesan;
}

/// Adapter inferensi Ollama lokal. Tidak menggunakan API key atau cloud.
class LayananOllama implements LayananAi {
  LayananOllama({
    this.model = const String.fromEnvironment(
      'OLLAMA_MODEL',
      defaultValue: 'qwen2.5:1.5b',
    ),
    String endpoint = const String.fromEnvironment(
      'OLLAMA_URL',
      defaultValue: 'http://127.0.0.1:11434/api/chat',
    ),
    http.Client Function()? buatClient,
    this.batasWaktu = const Duration(seconds: 90),
  }) : uri = Uri.parse(endpoint),
       _buatClient = buatClient ?? http.Client.new {
    if (!['http', 'https'].contains(uri.scheme) ||
        !['127.0.0.1', 'localhost', '::1', '10.0.2.2'].contains(uri.host) ||
        uri.userInfo.isNotEmpty) {
      throw ArgumentError(
        'Demo hanya menerima endpoint loopback atau host emulator Android.',
      );
    }
  }
  final String model;
  final Uri uri;
  final Duration batasWaktu;
  final http.Client Function() _buatClient;
  final Set<http.Client> _aktif = {};
  bool _ditutup = false;

  @override
  String get nama => 'Ollama / $model (model nyata)';

  @override
  Stream<String> kirim(String perintah) async* {
    if (_ditutup) {
      throw const GalatModel('Layanan telah ditutup. Buka ulang layar.');
    }
    if (perintah.trim().isEmpty) {
      throw const GalatModel('Pertanyaan wajib diisi.');
    }
    if (perintah.length > 4000) {
      throw const GalatModel('Batasi pertanyaan hingga 4000 karakter.');
    }
    final client = _buatClient();
    _aktif.add(client);
    try {
      final request =
          http.Request('POST', uri)
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode({
              'model': model,
              'stream': true,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Anda asisten belajar Flutter. Jawab dalam bahasa Indonesia dengan ringkas. Jangan mengklaim telah menjalankan kode. Jika tidak yakin, jelaskan keterbatasan Anda.',
                },
                {'role': 'user', 'content': perintah},
              ],
              'options': {'num_predict': 192, 'temperature': 0.2},
            });
      final response = await client.send(request).timeout(batasWaktu);
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw const GalatModel(
            'Model atau endpoint tidak ditemukan. Periksa ollama list dan OLLAMA_MODEL.',
          );
        }
        throw const GalatModel(
          'Ollama menolak permintaan. Periksa layanan dan konfigurasi model.',
        );
      }
      var selesai = false;
      var adaTeks = false;
      var jumlah = 0;
      await for (final line in response.stream
          .timeout(batasWaktu)
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        final event = jsonDecode(line);
        if (event is! Map<String, dynamic> || event.containsKey('error')) {
          throw const GalatModel('Layanan mengembalikan respons tidak valid.');
        }
        final message = event['message'];
        final content = message is Map ? message['content'] : null;
        if (content != null && content is! String) {
          throw const GalatModel('Format potongan respons tidak sesuai.');
        }
        if (content is String && content.isNotEmpty) {
          jumlah += content.length;
          if (jumlah > 32000) {
            throw const GalatModel('Respons melampaui batas demo.');
          }
          adaTeks = true;
          yield content;
        }
        if (event['done'] == true) {
          selesai = true;
          break;
        }
      }
      if (!selesai) {
        throw const GalatModel(
          'Stream terputus sebelum selesai.',
          SebabGalat.jaringan,
        );
      }
      if (!adaTeks) {
        throw const GalatModel(
          'Model selesai tanpa jawaban teks. Coba model lain.',
        );
      }
    } on GalatAi {
      rethrow;
    } on FormatException {
      throw const GalatModel('Respons Ollama bukan NDJSON yang valid.');
    } catch (_) {
      throw const GalatModel(
        'Tidak dapat menerima respons. Periksa Ollama, alamat, CORS, dan waktu pemuatan model.',
        SebabGalat.jaringan,
      );
    } finally {
      _aktif.remove(client);
      client.close();
    }
  }

  @override
  void tutup() {
    _ditutup = true;
    for (final client in _aktif.toList()) {
      client.close();
    }
    _aktif.clear();
  }
}
