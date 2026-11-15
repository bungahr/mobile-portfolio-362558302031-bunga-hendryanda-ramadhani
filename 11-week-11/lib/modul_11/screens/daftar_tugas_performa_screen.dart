import 'package:flutter/material.dart';

import '../data/sumber_tugas_contoh.dart';
import '../domain/filter_tugas.dart';
import '../domain/tugas_performa.dart';
import '../widgets/kartu_tugas_performa.dart';

class LayarDaftarTugasPerforma extends StatefulWidget {
  const LayarDaftarTugasPerforma({this.sumber, super.key});

  final List<TugasPerforma>? sumber;

  @override
  State<LayarDaftarTugasPerforma> createState() =>
      _LayarDaftarTugasPerformaState();
}

class _LayarDaftarTugasPerformaState extends State<LayarDaftarTugasPerforma> {
  final TextEditingController _controller = TextEditingController();

  late final List<TugasPerforma> _semuaTugas;
  late List<TugasPerforma> _hasil;

  KriteriaFilter _kriteria = const KriteriaFilter();

  @override
  void initState() {
    super.initState();
    _semuaTugas = widget.sumber ?? buatTugasContoh();
    _hasil = saringTugas(_semuaTugas, _kriteria);
  }

  void _terapkan() {
    setState(() {
      _kriteria = _kriteria.salinDengan(kueri: _controller.text);
      _hasil = saringTugas(_semuaTugas, _kriteria);
    });
  }

  void _pilihFilter(StatusTugas? status) {
    setState(() {
      _kriteria = _kriteria.salinDengan(
        status: status,
        hapusStatus: status == null,
      );
      _hasil = saringTugas(_semuaTugas, _kriteria);
    });
  }

  void _pilihMataKuliah(String? mataKuliah) {
    setState(() {
      _kriteria = _kriteria.salinDengan(
        mataKuliah: mataKuliah,
        hapusMataKuliah: mataKuliah == null,
      );
      _hasil = saringTugas(_semuaTugas, _kriteria);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar 1.000 Tugas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              key: const ValueKey('task-search'),
              controller: _controller,
              onChanged: (_) => _terapkan(),
              decoration: InputDecoration(
                hintText: 'Cari judul atau mata kuliah...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _controller.clear();
                    _terapkan();
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buatChip('Semua', null),
                _buatChip('Aktif', StatusTugas.aktif),
                _buatChip('Selesai', StatusTugas.selesai),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filter mata kuliah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buatChipMataKuliah('Semua Mata Kuliah', null),
                ...daftarMataKuliahContoh.map(
                  (mataKuliah) => _buatChipMataKuliah(mataKuliah, mataKuliah),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hasil tugas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Menampilkan ${_hasil.length} dari ${_semuaTugas.length} tugas',
                  key: const ValueKey('result-count'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _hasil.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tugas yang cocok.',
                      key: ValueKey('empty-message'),
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('task-list'),
                    itemCount: _hasil.length,
                    itemBuilder: (context, index) {
                      final tugas = _hasil[index];
                      return KartuTugasPerforma(tugas: tugas);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buatChip(String label, StatusTugas? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _kriteria.status == status,
        onSelected: (_) => _pilihFilter(status),
      ),
    );
  }

  Widget _buatChipMataKuliah(String label, String? mataKuliah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        key: ValueKey('filter-mk-${mataKuliah ?? 'semua'}'),
        label: Text(label),
        selected: _kriteria.mataKuliah == mataKuliah,
        onSelected: (_) => _pilihMataKuliah(mataKuliah),
      ),
    );
  }
}
