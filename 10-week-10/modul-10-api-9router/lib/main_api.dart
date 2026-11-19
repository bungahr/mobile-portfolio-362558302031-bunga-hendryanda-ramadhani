import 'package:flutter/material.dart';
import 'ai_nyata/layanan_api.dart';
import 'modul_10/data/layanan_ai_lokal.dart';
import 'modul_10/presentation/status_obrolan.dart';
import 'modul_10/presentation/view_model_obrolan.dart';
import 'modul_10/widgets/gelembung_pesan.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const DemoApi9Router(),
  ),
);

class DemoApi9Router extends StatefulWidget {
  const DemoApi9Router({super.key});
  @override
  State<DemoApi9Router> createState() => _DemoApi9RouterState();
}

class _DemoApi9RouterState extends State<DemoApi9Router> {
  final _input = TextEditingController();
  late ViewModelObrolan _model = ViewModelObrolan(layanan: LayananAiLokal());
  bool _nyata = false;

  void _ganti(bool nyata) {
    if (_model.sedangSibuk) return;
    final lama = _model;
    setState(() {
      _nyata = nyata;
      _model = ViewModelObrolan(
        layanan: nyata ? LayananApi() : LayananAiLokal(),
      );
    });
    lama.dispose();
  }

  Future<void> _kirim() async {
    final teks = _input.text;
    if (teks.trim().isEmpty || _model.sedangSibuk) return;
    _input.clear();
    await _model.kirim(teks);
  }

  @override
  void dispose() {
    _model.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo dosen: API 9router')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _model,
        builder: (context, _) {
          final status = _model.status;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<bool>(
                      value: _nyata,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Simulator / jawaban tetap'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('9router API / melalui proxy lokal'),
                        ),
                      ],
                      onChanged:
                          _model.sedangSibuk
                              ? null
                              : (value) {
                                if (value != null) _ganti(value);
                              },
                    ),
                    Text(
                      _nyata
                          ? 'Teks dikirim melalui proxy ke 9router dan provider yang dikonfigurasi. Jawaban dapat keliru. Riwayat tidak dikirim ulang; setiap pertanyaan berdiri sendiri.'
                          : 'Simulator memilih jawaban tetap berdasarkan kata kunci. Tidak ada inferensi model.',
                    ),
                    Text('Penyedia: ${_model.namaPenyedia}'),
                    Text('Status: ${status.runtimeType}'),
                  ],
                ),
              ),
              if (status is ObrolanGagal)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    status.galat.pesanPengguna,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_model.sedangSibuk) const LinearProgressIndicator(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _model.pesan.length,
                  itemBuilder:
                      (context, i) => GelembungPesan(pesan: _model.pesan[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        enabled: !_model.sedangSibuk,
                        maxLength: 4000,
                        decoration: const InputDecoration(
                          labelText: 'Pertanyaan contoh tanpa data pribadi',
                        ),
                        onSubmitted: (_) => _kirim(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_model.sedangSibuk)
                      TextButton(
                        onPressed: _model.batal,
                        child: const Text('Hentikan'),
                      )
                    else
                      FilledButton(
                        onPressed: _kirim,
                        child: const Text('Kirim'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
