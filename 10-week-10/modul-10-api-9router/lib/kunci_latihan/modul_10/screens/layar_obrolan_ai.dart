import 'package:flutter/material.dart';

import '../data/layanan_ai_lokal.dart';
import '../data/layanan_ai_ringkas.dart';
import '../data/layanan_ai_terbatas.dart';
import '../domain/galat_ai.dart';
import '../domain/kontrak_layanan_ai.dart';
import '../domain/penjaga_kuota.dart';
import '../domain/pesan_kuota.dart';
import '../domain/pesan_ai.dart';
import '../presentation/status_obrolan.dart';
import '../presentation/view_model_obrolan.dart';
import '../widgets/bilah_kuota.dart';
import '../widgets/gelembung_pesan.dart';
import '../widgets/kartu_pengungkapan.dart';

/// Layar percakapan dengan layanan AI.
///
/// Layar ini hanya mengurus tampilan dan siklus hidup objek. Seluruh keputusan
/// tentang keadaan percakapan berada di [ViewModelObrolan], sehingga layar dapat
/// diuji dengan menyuntikkan penyedia tiruan.
/// KUNCI LATIHAN 1: tiga pilihan penyedia.
enum PilihanPenyedia { lokal, ringkas, terbatas }

class LayarObrolanAi extends StatefulWidget {
  const LayarObrolanAi({super.key});

  @override
  State<LayarObrolanAi> createState() => _LayarObrolanAiState();
}

class _LayarObrolanAiState extends State<LayarObrolanAi> {
  final TextEditingController _pengendali = TextEditingController();
  final ScrollController _gulir = ScrollController();
  final PenjagaKuota _kuota =
      PenjagaKuota(batas: 5, jendela: const Duration(minutes: 1));
  late final LayananAi _dasar;
  late ViewModelObrolan _model;
  PilihanPenyedia _pilihan = PilihanPenyedia.lokal;

  @override
  void initState() {
    super.initState();
    _dasar = LayananAiLokal(penjaga: _kuota);
    _model = _buatModel();
  }

  ViewModelObrolan _buatModel() {
    // Satu-satunya tempat yang berubah untuk penyedia ketiga.
    final LayananAi layanan = switch (_pilihan) {
      PilihanPenyedia.lokal => _dasar,
      PilihanPenyedia.ringkas => LayananAiRingkas(_dasar),
      PilihanPenyedia.terbatas => const LayananAiTerbatas(),
    };
    final ViewModelObrolan model = ViewModelObrolan(layanan: layanan);
    model.addListener(_keBawah);
    return model;
  }

  /// Menggulir daftar ke bawah setelah bingkai berikutnya digambar.
  void _keBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gulir.hasClients) {
        _gulir.jumpTo(_gulir.position.maxScrollExtent);
      }
    });
  }

  void _tukarPenyedia(PilihanPenyedia pilihan) {
    if (pilihan == _pilihan) return;
    final ViewModelObrolan lama = _model;
    setState(() {
      _pilihan = pilihan;
      _model = _buatModel();
    });
    lama.dispose();
  }

  Future<void> _kirim() async {
    final String teks = _pengendali.text;
    _pengendali.clear();
    await _model.kirim(teks);
  }

  void _hentikan() {
    _model.batal();
  }

  @override
  void dispose() {
    _pengendali.dispose();
    _gulir.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obrolan AI'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Kosongkan percakapan',
            onPressed: _model.bersihkan,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _model,
        builder: (BuildContext context, Widget? _) {
          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: KartuPengungkapan(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: BilahKuota(sisa: _kuota.sisa, batas: _kuota.batas),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Penyedia: ${_model.namaPenyedia}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    SegmentedButton<PilihanPenyedia>(
                      showSelectedIcon: false,
                      segments: const <ButtonSegment<PilihanPenyedia>>[
                        ButtonSegment<PilihanPenyedia>(
                          value: PilihanPenyedia.lokal,
                          label: Text('Lokal'),
                        ),
                        ButtonSegment<PilihanPenyedia>(
                          value: PilihanPenyedia.ringkas,
                          label: Text('Ringkas'),
                        ),
                        ButtonSegment<PilihanPenyedia>(
                          value: PilihanPenyedia.terbatas,
                          label: Text('Terbatas'),
                        ),
                      ],
                      selected: <PilihanPenyedia>{_pilihan},
                      onSelectionChanged: (Set<PilihanPenyedia> s) =>
                          _tukarPenyedia(s.first),
                    ),
                  ],
                ),
              ),
              Expanded(child: _isi()),
              _bilahMasukan(),
            ],
          );
        },
      ),
    );
  }

  Widget _isi() {
    final List<PesanAi> pesan = _model.pesan;
    if (pesan.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada percakapan. Ajukan pertanyaan untuk memulai.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _gulir,
      padding: const EdgeInsets.all(16),
      itemCount: pesan.length,
      itemBuilder: (BuildContext context, int i) =>
          GelembungPesan(pesan: pesan[i]),
    );
  }

  Widget _bilahMasukan() {
    final StatusObrolan status = _model.status;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (status is ObrolanGagal)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _pesanGagal(status),
              ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _pengendali,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _kirim(),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pertanyaan...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_model.sedangSibuk)
                  IconButton.filledTonal(
                    onPressed: _hentikan,
                    tooltip: 'Hentikan',
                    icon: const Icon(Icons.stop),
                  )
                else
                  IconButton.filled(
                    onPressed: _kirim,
                    tooltip: 'Kirim',
                    icon: const Icon(Icons.send),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pesanGagal(ObrolanGagal status) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: skema.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 18, color: skema.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              // KUNCI LATIHAN 2: sisa waktu dihitung sekali saat kegagalan
              // digambar — tanpa Timer yang berdetak setiap detik.
              status.galat.sebab == SebabGalat.batasKuota
                  ? pesanKuotaHabis(_kuota.tungguSampai())
                  : status.galat.pesanPengguna,
              style: TextStyle(color: skema.onErrorContainer, fontSize: 13),
            ),
          ),
          if (status.galat.layakDiulang)
            TextButton(
              onPressed: _model.ulangi,
              child: const Text('Coba lagi'),
            )
          else
            TextButton(
              onPressed: _model.akuiGalat,
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }
}
