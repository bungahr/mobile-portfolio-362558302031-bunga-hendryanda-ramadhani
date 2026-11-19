import 'package:flutter/material.dart';
import 'ai_nyata/layanan_ollama.dart';
import 'modul_10/data/layanan_ai_lokal.dart';
import 'modul_10/presentation/status_obrolan.dart';
import 'modul_10/presentation/view_model_obrolan.dart';
import 'modul_10/widgets/gelembung_pesan.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const DemoModelNyata(),
  ),
);

class DemoModelNyata extends StatefulWidget {
  const DemoModelNyata({super.key});
  @override
  State<DemoModelNyata> createState() => _DemoModelNyataState();
}

class _DemoModelNyataState extends State<DemoModelNyata> {
  final _input = TextEditingController();
  late ViewModelObrolan _model = ViewModelObrolan(layanan: LayananAiLokal());
  bool _nyata = false;

  void _ganti(bool nyata) {
    if (_model.sedangSibuk) return;
    final lama = _model;
    setState(() {
      _nyata = nyata;
      _model = ViewModelObrolan(
        layanan: nyata ? LayananOllama() : LayananAiLokal(),
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
    appBar: AppBar(title: const Text('Demo dosen: simulator dan model nyata')),
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
                          child: Text('Ollama lokal / inferensi model nyata'),
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
                          ? 'Teks dikirim ke Ollama di komputer dosen. Jawaban dapat keliru. Riwayat tidak dikirim ulang; setiap pertanyaan berdiri sendiri.'
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
