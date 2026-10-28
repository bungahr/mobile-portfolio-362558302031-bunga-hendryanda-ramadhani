import 'package:flutter/material.dart';

import '../../../modul_07/domain/repositori_tugas.dart';
import '../../../modul_07/domain/tugas.dart';
import '../../../modul_07/presentation/state_daftar_tugas.dart';
import '../../../modul_07/widgets/kartu_tugas.dart';
import '../core/lokator.dart';
import '../presentation/view_model_tugas_pengayaan.dart';
import '../usecase/hapus_tugas.dart';
import '../usecase/muat_daftar_tugas.dart';
import '../usecase/tambah_tugas.dart';
import '../usecase/ubah_status_tugas.dart';

class DaftarTugasPengayaanScreen extends StatefulWidget {
  const DaftarTugasPengayaanScreen({super.key, required this.viewModel});

  final ViewModelTugasPengayaan viewModel;

  @override
  State<DaftarTugasPengayaanScreen> createState() =>
      _DaftarTugasPengayaanScreenState();
}

class _DaftarTugasPengayaanScreenState
    extends State<DaftarTugasPengayaanScreen> {
  final TextEditingController _judul = TextEditingController();
  final TextEditingController _mataKuliah = TextEditingController();

  String? _idSibuk;
  bool _papanTerbuka = false;

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
    if (_judul.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul tugas belum diisi.')));
      return;
    }
    FocusScope.of(context).unfocus();
    final bool berhasil = await widget.viewModel.tambah(
      judul: _judul.text,
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
        title: const Text('Daftar Tugas — Fase B'),
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
              _PapanLokator(
                terbuka: _papanTerbuka,
                onUbah: (bool nilai) => setState(() => _papanTerbuka = nilai),
              ),
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  state.pesanGagal ?? 'Gagal memuat tugas.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: widget.viewModel.muat,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        );
      case StatusMuat.siap:
        if (state.kosong) {
          return const Center(child: Text('Belum ada tugas.'));
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

class _PapanLokator extends StatelessWidget {
  const _PapanLokator({required this.terbuka, required this.onUbah});

  final bool terbuka;
  final ValueChanged<bool> onUbah;

  @override
  Widget build(BuildContext context) {
    final ColorScheme skema = Theme.of(context).colorScheme;

    final List<(String, String)> isi = <(String, String)>[
      (
        'RepositoriTugas',
        lokator.isRegistered<RepositoriTugas>()
            ? lokator<RepositoriTugas>().runtimeType.toString()
            : 'belum terdaftar',
      ),
      (
        'MuatDaftarTugas',
        lokator.isRegistered<MuatDaftarTugas>() ? 'siap' : 'belum terdaftar',
      ),
      (
        'TambahTugas',
        lokator.isRegistered<TambahTugas>() ? 'siap' : 'belum terdaftar',
      ),
      (
        'UbahStatusTugas',
        lokator.isRegistered<UbahStatusTugas>() ? 'siap' : 'belum terdaftar',
      ),
      (
        'HapusTugas',
        lokator.isRegistered<HapusTugas>() ? 'siap' : 'belum terdaftar',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: skema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            dense: true,
            leading: const Icon(Icons.account_tree_outlined, size: 20),
            title: const Text('Isi service locator'),
            subtitle: const Text(
              'get_it menyembunyikan rakitan — papan ini '
              'menampilkannya kembali',
            ),
            trailing: Icon(terbuka ? Icons.expand_less : Icons.expand_more),
            onTap: () => onUbah(!terbuka),
          ),
          if (terbuka)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: <Widget>[
                  for (final (String nama, String nilai) in isi)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            child: Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              nilai,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: nilai == 'belum terdaftar'
                                    ? skema.error
                                    : skema.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
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
