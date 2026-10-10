import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.storage});

  /// Bisa diganti dari luar ketika pengujian.
  final TaskStorage? storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskStorage _storage = widget.storage ?? const TaskStorage();

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;
  DateTime? _waktuSimpan;

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  // Memuat daftar tugas dari penyimpanan.
  Future<void> _muat({bool pulihkanJsonRusak = false}) async {
    setState(() {
      _tugas = null;
      _error = null;
      _waktuSimpan = null;
    });

    try {
      final List<Task> hasil = await _storage.muat(
        pulihkanJsonRusak: pulihkanJsonRusak,
      );

      final DateTime? waktu = await _storage.bacaWaktuSimpan();

      final String? pesan = TaskStorage.pesanPemulihan;

      if (!mounted) return;

      setState(() {
        _tugas = hasil;
        _waktuSimpan = waktu;
        _error = null;
      });

      if (pesan != null) {
        _pesan(pesan);
        TaskStorage.pesanPemulihan = null;
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
      });
    }
  }

  // Menyimpan daftar yang berubah.
  Future<bool> _simpanDaftar(
    List<Task> daftarBaru, {
    String? pesan,
    List<Task>? daftarSebelumnya,
  }) async {
    final List<Task>? cadangan = daftarSebelumnya ?? _tugas;

    setState(() {
      _tugas = daftarBaru;
      _sedangMenyimpan = true;
    });

    try {
      await _storage.simpan(daftarBaru);

      final DateTime? waktu = await _storage.bacaWaktuSimpan();

      if (!mounted) return true;

      setState(() {
        _sedangMenyimpan = false;
        _waktuSimpan = waktu;
      });

      if (pesan != null) {
        _pesan(pesan);
      }

      return true;
    } catch (e) {
      if (!mounted) return false;

      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
      });

      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');

      return false;
    }
  }

  // Mengubah status selesai atau belum selesai.
  Future<void> _ubahStatus(Task tugas) async {
    final List<Task>? sekarang = _tugas;

    if (sekarang == null) return;

    final List<Task> baru = sekarang
        .map((Task t) => t.id == tugas.id ? t.copyWith(done: !t.done) : t)
        .toList(growable: true);

    await _simpanDaftar(baru, daftarSebelumnya: sekarang);
  }

  // Membuka dialog tambah tugas.
  Future<void> _tambahTugas() async {
    final Task? hasil = await showDialog<Task>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _TambahTugasDialog();
      },
    );

    if (hasil == null || !mounted) return;

    final List<Task>? sekarang = _tugas;

    if (sekarang == null) return;

    final List<Task> baru = List<Task>.of(sekarang)..add(hasil);

    await _simpanDaftar(
      baru,
      pesan: 'Tugas berhasil ditambahkan.',
      daftarSebelumnya: sekarang,
    );
  }

  // Menghapus tugas dan menyediakan tombol urungkan.
  Future<void> _hapusDenganUrungkan(Task tugas) async {
    final List<Task>? sebelumnya = _tugas;

    if (sebelumnya == null) return;

    final List<Task> baru = List<Task>.of(sebelumnya)
      ..removeWhere((Task t) => t.id == tugas.id);

    final bool berhasil = await _simpanDaftar(
      baru,
      daftarSebelumnya: sebelumnya,
    );

    if (!berhasil || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas dihapus.'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () {
            unawaited(
              _simpanDaftar(sebelumnya, pesan: 'Penghapusan dibatalkan.'),
            );
          },
        ),
      ),
    );
  }

  // Membuat data rusak untuk menguji keadaan gagal.
  Future<void> _rusakkanDataDemo() async {
    try {
      await _storage.rusakkanUntukDemo();

      if (!mounted) return;

      await _muat();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
      });
    }
  }

  // Menghapus data rusak dan mengembalikan aplikasi ke keadaan kosong.
  Future<void> _hapusDataRusak() async {
    try {
      await _storage.hapusSemua();
      await _storage.simpan(<Task>[]);

      if (!mounted) return;

      await _muat();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
      });
    }
  }

  void _pesan(String teks) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  String _rapikanPesan(Object error) {
    if (error is FormatException) {
      return error.message.toString();
    }

    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  // Keadaan loading.
  Widget _keadaanMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Sedang memuat daftar tugas...'),
        ],
      ),
    );
  }

  // Keadaan error.
  Widget _keadaanGagal() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Daftar tugas gagal dimuat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_rapikanPesan(_error!), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => unawaited(_muat()),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => unawaited(_hapusDataRusak()),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus Data Rusak'),
            ),
          ],
        ),
      ),
    );
  }

  // Keadaan ketika daftar kosong.
  Widget _keadaanKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.task_alt,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada tugas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan tombol Tambah Tugas '
              'untuk mencatat tugas praktikum.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _tambahTugas,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan daftar, ringkasan, dan counter Latihan 3.
  Widget _keadaanDaftar(List<Task> tugas) {
    final int selesai = tugas.where((Task t) => t.done).length;

    final int belumSelesai = tugas.length - selesai;

    return Column(
      children: <Widget>[
        if (_sedangMenyimpan) const LinearProgressIndicator(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jumlah record yang ditulis: '
              '${TaskStorage.jumlahTugasDitulis}',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${tugas.length} tugas · '
              '$belumSelesai belum selesai · '
              '$selesai selesai',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
            itemCount: tugas.length,
            itemBuilder: (BuildContext context, int index) {
              final Task tugasItem = tugas[index];

              return Dismissible(
                key: ValueKey<String>(tugasItem.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) {
                  unawaited(_hapusDenganUrungkan(tugasItem));
                },
                child: TaskTile(
                  task: tugasItem,
                  onToggle: (Task t) {
                    unawaited(_ubahStatus(t));
                  },
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
        title: const Text('Tugas Praktikum'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _sedangMenyimpan ? null : () => unawaited(_muat()),
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu lainnya',
            onSelected: (String pilihan) {
              if (pilihan == 'rusak') {
                unawaited(_rusakkanDataDemo());
              }

              if (pilihan == 'muat') {
                unawaited(_muat());
              }

              if (pilihan == 'cadangkan') {
                unawaited(_muat(pulihkanJsonRusak: true));
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'muat',
                    child: Text('Muat ulang daftar'),
                  ),
                  PopupMenuItem<String>(
                    value: 'rusak',
                    child: Text('Rusakkan data (demo keadaan gagal)'),
                  ),
                  PopupMenuItem<String>(
                    value: 'cadangkan',
                    child: Text('Pulihkan data rusak (latihan 4)'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_waktuSimpan != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Terakhir disimpan: '
                  '${_waktuSimpan!.toLocal()}',
                ),
              ),
            ),

          Expanded(
            child: _error != null
                ? _keadaanGagal()
                : _tugas == null
                ? _keadaanMemuat()
                : _tugas!.isEmpty
                ? _keadaanKosong()
                : _keadaanDaftar(_tugas!),
          ),
        ],
      ),
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

// Dialog terpisah supaya controller tidak dibuang
// saat TextFormField masih digunakan oleh animasi dialog.
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
            if (!_kunciForm.currentState!.validate()) {
              return;
            }

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
