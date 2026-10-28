class BarisTidakAda implements Exception {
  const BarisTidakAda(this.id);

  final String id;

  @override
  String toString() => 'BarisTidakAda($id)';
}

class SumberTugasMemori {
  SumberTugasMemori({bool denganContoh = true}) {
    if (denganContoh) {
      // Data contoh berurutan terbaru dahulu. Simpan internal dalam urutan
      // penyisipan dan salin setiap Map agar data contoh tetap tidak berubah.
      _baris.addAll(getSampleRows().reversed.map(Map<String, Object?>.of));
      _urutan = _baris.length;
    }
  }

  final List<Map<String, Object?>> _baris = <Map<String, Object?>>[];

  int _urutan = 0;

  int get jumlahBaris => _baris.length;

  bool gagalSaatMuat = false;

  bool gagalSaatTulis = false;

  Future<List<Map<String, Object?>>> ambilSemua() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (gagalSaatMuat) {
      throw StateError('Penyimpanan sedang tidak bisa diakses.');
    }
    // Salin list beserta Map-nya agar perubahan snapshot tidak mengubah data.
    return _baris.reversed.map(Map<String, Object?>.of).toList();
  }

  Future<Map<String, Object?>> sisipkan(Map<String, Object?> nilai) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (gagalSaatTulis) {
      throw StateError('Penyimpanan menolak penulisan.');
    }
    _urutan++;
    final Map<String, Object?> baris = <String, Object?>{
      ...nilai,
      // Identitas ditentukan sumber data, bukan ditimpa oleh masukan.
      'id': 'tgs-$_urutan',
    };
    _baris.add(baris);
    return Map<String, Object?>.of(baris);
  }

  Future<void> perbaruiSelesai(String id, bool selesai) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (gagalSaatTulis) {
      throw StateError('Penyimpanan menolak penulisan.');
    }
    final int posisi = _posisi(id);
    if (posisi < 0) throw BarisTidakAda(id);
    _baris[posisi] = <String, Object?>{
      ..._baris[posisi],
      'selesai': selesai ? 1 : 0,
    };
  }

  Future<void> hapus(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (gagalSaatTulis) {
      throw StateError('Penyimpanan menolak penulisan.');
    }
    final int posisi = _posisi(id);
    if (posisi < 0) throw BarisTidakAda(id);
    _baris.removeAt(posisi);
  }

  int _posisi(String id) {
    for (int i = 0; i < _baris.length; i++) {
      if (_baris[i]['id'] == id) return i;
    }
    return -1;
  }

  static List<Map<String, Object?>> getSampleRows() {
    return const <Map<String, Object?>>[
      <String, Object?>{
        'id': 'tgs-3',
        'judul': 'Menyiapkan basis data untuk proyek akhir',
        'mata_kuliah': 'Basis Data Lanjut',
        'selesai': 0,
        'dibuat_pada': '2026-09-17',
        'prioritas': 1,
      },
      <String, Object?>{
        'id': 'tgs-2',
        'judul': 'Membaca dokumentasi SharedPreferences',
        'mata_kuliah': 'Pemrograman Perangkat Bergerak',
        'selesai': 0,
        'dibuat_pada': '2026-09-16',
        'prioritas': 2,
      },
      <String, Object?>{
        'id': 'tgs-1',
        'judul': 'Menyelesaikan laporan praktikum Modul 05',
        'mata_kuliah': 'Pemrograman Perangkat Bergerak',
        'selesai': 1,
        'dibuat_pada': '2026-09-15',
        'prioritas': 3,
      },
    ];
  }
}
