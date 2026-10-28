import 'package:flutter/material.dart';

import '../domain/tugas.dart';
import '../presentation/state_daftar_tugas.dart';
import '../presentation/view_model_daftar_tugas.dart';
import '../widgets/kartu_tugas.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key, required this.viewModel});

  final ViewModelDaftarTugas viewModel;

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  final TextEditingController _judul = TextEditingController();
  final TextEditingController _mataKuliah = TextEditingController();

  String? _idSibuk;

  @override
  void initState() {
    super.initState();
    widget.viewModel.muat();
  }

  @override
  void dispose() {
    _judul.dispose();
    _mataKuliah.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final String judul = _judul.text;
    if (judul.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul tugas belum diisi.')));
      return;
    }

    FocusScope.of(context).unfocus();
    final bool berhasil = await widget.viewModel.tambah(
      judul: judul,
      mataKuliah: _mataKuliah.text,
    );
    if (!mounted) return;
    if (berhasil) {
      _judul.clear();
      _mataKuliah.clear();
    }
  }

  Future<void> _ubahStatus(Tugas tugas) async {
    setState(() => _idSibuk = tugas.id);
    await widget.viewModel.ubahStatus(tugas);
    if (!mounted) return;
    setState(() => _idSibuk = null);
  }

  Future<void> _hapus(Tugas tugas) async {
    setState(() => _idSibuk = tugas.id);
    await widget.viewModel.hapus(tugas.id);
    if (!mounted) return;
    setState(() => _idSibuk = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.muat,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (BuildContext context, _) {
          final StateDaftarTugas state = widget.viewModel.state;
          return Column(
            children: <Widget>[
              _FormTambah(
                judul: _judul,
                mataKuliah: _mataKuliah,
                sedangMemuat: state.sedangMemuat,
                onKirim: _kirim,
              ),
              if (state.pesanGagal != null && !state.adaGagal)
                _PesanGagal(
                  pesan: state.pesanGagal!,
                  onTutup: widget.viewModel.bersihkanPesanGagal,
                ),
              if (state.status == StatusMuat.siap && !state.kosong)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.jumlahBelumSelesai} dari ${state.daftar.length} belum selesai',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              Expanded(child: _bangunIsi(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _bangunIsi(StateDaftarTugas state) {
    switch (state.status) {
      case StatusMuat.awal:
        return const SizedBox.shrink();

      case StatusMuat.memuat:
        return const Center(child: CircularProgressIndicator());

      case StatusMuat.gagal:
        return _TampilanGagal(
          pesan: state.pesanGagal ?? 'Gagal memuat tugas.',
          onCobaLagi: widget.viewModel.muat,
        );

      case StatusMuat.siap:
        if (state.kosong) {
          return const _TampilanKosong();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: state.daftar.length,
          itemBuilder: (BuildContext context, int i) {
            final Tugas tugas = state.daftar[i];
            return KartuTugas(
              tugas: tugas,
              sedangSibuk: _idSibuk == tugas.id,
              onUbahStatus: () => _ubahStatus(tugas),
              onHapus: () => _hapus(tugas),
            );
          },
        );
    }
  }
}

class _FormTambah extends StatelessWidget {
  const _FormTambah({
    required this.judul,
    required this.mataKuliah,
    required this.sedangMemuat,
    required this.onKirim,
  });

  final TextEditingController judul;
  final TextEditingController mataKuliah;
  final bool sedangMemuat;
  final VoidCallback onKirim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: <Widget>[
          TextField(
            controller: judul,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Judul tugas baru',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: mataKuliah,
                  decoration: const InputDecoration(
                    labelText: 'Mata kuliah (opsional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => onKirim(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: sedangMemuat ? null : onKirim,
                child: const Text('Tambah'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PesanGagal extends StatelessWidget {
  const _PesanGagal({required this.pesan, required this.onTutup});

  final String pesan;
  final VoidCallback onTutup;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: skema.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 20, color: skema.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(pesan, style: TextStyle(color: skema.onErrorContainer)),
          ),
          IconButton(
            tooltip: 'Tutup pesan',
            icon: const Icon(Icons.close, size: 18),
            onPressed: onTutup,
          ),
        ],
      ),
    );
  }
}

class _TampilanKosong extends StatelessWidget {
  const _TampilanKosong();

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.inbox_outlined, size: 48, color: skema.outline),
          const SizedBox(height: 12),
          const Text('Belum ada tugas.'),
          const SizedBox(height: 4),
          Text(
            'Tambahkan tugas pertama lewat kolom di atas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TampilanGagal extends StatelessWidget {
  const _TampilanGagal({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_off, size: 48, color: skema.error),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
