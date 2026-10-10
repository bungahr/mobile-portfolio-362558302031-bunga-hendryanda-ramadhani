import 'dart:async';

import 'package:flutter/material.dart';

import '../../../modul_05/models/task.dart';
import '../../../modul_05/widgets/task_tile.dart';
import '../repositories/task_repository.dart';

class TaskListPengayaanScreen extends StatefulWidget {
  const TaskListPengayaanScreen({
    super.key,
    required this.repository,
    required this.sumber,
    required this.onGantiSumber,
  });

  final TaskRepository repository;
  final SumberDataTugas sumber;
  final ValueChanged<SumberDataTugas> onGantiSumber;

  @override
  State<TaskListPengayaanScreen> createState() =>
      _TaskListPengayaanScreenState();
}

class _TaskListPengayaanScreenState extends State<TaskListPengayaanScreen> {
  TaskRepository get _repo => widget.repository;

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;
  int _jumlahTersimpan = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _tugas = null;
      _error = null;
    });
    try {
      final List<Task> hasil = await _repo.ambilSemua();
      final int jumlah = await _repo.jumlah();
      if (!mounted) return;
      setState(() {
        _tugas = hasil;
        _jumlahTersimpan = jumlah;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _jalankan(Future<void> Function() aksi, {String? pesan}) async {
    final List<Task>? cadangan = _tugas;
    setState(() => _sedangMenyimpan = true);
    try {
      await aksi();
      final List<Task> hasil = await _repo.ambilSemua();
      final int jumlah = await _repo.jumlah();
      if (!mounted) return;
      setState(() {
        _tugas = hasil;
        _jumlahTersimpan = jumlah;
        _sedangMenyimpan = false;
      });
      if (pesan != null) _pesan(pesan);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
        _error = e;
      });
      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');
    }
  }

  Future<void> _ubahStatus(Task tugas) async {
    await _jalankan(
      () => _repo.perbarui(tugas.copyWith(done: !tugas.done)),
      pesan: 'Status tugas diperbarui.',
    );
  }

  Future<void> _tambahTugas() async {
    final Task? hasil = await showDialog<Task>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _TambahTugasDialog();
      },
    );

    if (hasil == null || !mounted) return;

    await _jalankan(
      () => _repo.tambah(hasil),
      pesan: 'Tugas berhasil ditambahkan.',
    );
  }

  Future<void> _hapus(Task tugas) async {
    await _jalankan(() => _repo.hapus(tugas.id));
    if (!mounted || _error != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas dihapus.'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => unawaited(
            _jalankan(() => _repo.tambah(tugas), pesan: 'Tugas dikembalikan.'),
          ),
        ),
      ),
    );
  }

  String _rapikanPesan(Object error) {
    if (error is FormatException) return error.message.toString();
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Widget _memuat() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text('Sedang memuat daftar tugas...'),
      ],
    ),
  );

  Widget _gagal() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 56),
          const Text('Daftar tugas gagal dimuat'),
          const SizedBox(height: 8),
          Text(_rapikanPesan(_error!), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => unawaited(_muat()),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );

  Widget _kosong() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.task_alt, size: 60),
          const SizedBox(height: 12),
          const Text('Belum ada tugas', style: TextStyle(fontSize: 20)),
          const Text('Tekan Tambah Tugas untuk mulai mencatat tugas.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _tambahTugas,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tugas'),
          ),
        ],
      ),
    ),
  );

  Widget _daftar(List<Task> tugas) {
    final int selesai = tugas.where((Task t) => t.done).length;
    final int belum = tugas.length - selesai;
    return Column(
      children: <Widget>[
        if (_sedangMenyimpan) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${tugas.length} tugas · $belum belum selesai · $selesai selesai',
              ),
              const SizedBox(height: 4),
              Text('jumlah() dari ${widget.sumber.label}: $_jumlahTersimpan'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
            itemCount: tugas.length,
            itemBuilder: (BuildContext context, int index) {
              final Task tugasItem = tugas[index];
              return Dismissible(
                key: ValueKey<String>(tugasItem.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) => unawaited(_hapus(tugasItem)),
                child: TaskTile(
                  task: tugasItem,
                  onToggle: (Task t) => unawaited(_ubahStatus(t)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tugas Praktikum · ${widget.sumber.label}'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => unawaited(_muat()),
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<SumberDataTugas>(
            tooltip: 'Ganti sumber data',
            onSelected: widget.onGantiSumber,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SumberDataTugas>>[
                  const PopupMenuItem(
                    value: SumberDataTugas.sharedPreferences,
                    child: Text('Pakai SharedPreferences'),
                  ),
                  const PopupMenuItem(
                    value: SumberDataTugas.sqlite,
                    child: Text('Pakai SQLite'),
                  ),
                ],
          ),
        ],
      ),
      body: _error != null
          ? _gagal()
          : _tugas == null
          ? _memuat()
          : _tugas!.isEmpty
          ? _kosong()
          : _daftar(_tugas!),
      floatingActionButton:
          _error == null && _tugas != null && _tugas!.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _tambahTugas,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            )
          : null,
    );
  }
}

class _TambahTugasDialog extends StatefulWidget {
  const _TambahTugasDialog();

  @override
  State<_TambahTugasDialog> createState() => _TambahTugasDialogState();
}

class _TambahTugasDialogState extends State<_TambahTugasDialog> {
  final TextEditingController _judulController = TextEditingController();

  final TextEditingController _mataKuliahController = TextEditingController();

  final GlobalKey<FormState> _kunciForm = GlobalKey<FormState>();

  int _prioritasDipilih = 2;

  @override
  void dispose() {
    _judulController.dispose();
    _mataKuliahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Tugas'),
      content: SingleChildScrollView(
        child: Form(
          key: _kunciForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Judul tugas wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mataKuliahController,
                decoration: const InputDecoration(
                  labelText: 'Mata kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Mata kuliah wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Prioritas'),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(value: 1, label: Text('Tinggi')),
                  ButtonSegment<int>(value: 2, label: Text('Sedang')),
                  ButtonSegment<int>(value: 3, label: Text('Rendah')),
                ],
                selected: <int>{_prioritasDipilih},
                onSelectionChanged: (Set<int> nilai) {
                  setState(() {
                    _prioritasDipilih = nilai.first;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!_kunciForm.currentState!.validate()) return;

            final DateTime sekarang = DateTime.now();

            final Task tugas = Task(
              id: sekarang.microsecondsSinceEpoch.toString(),
              title: _judulController.text.trim(),
              course: _mataKuliahController.text.trim(),
              createdAt: sekarang.toIso8601String(),
              prioritas: _prioritasDipilih,
            );

            Navigator.pop(context, tugas);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
