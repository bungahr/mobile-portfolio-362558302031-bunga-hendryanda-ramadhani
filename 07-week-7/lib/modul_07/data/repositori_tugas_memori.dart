import '../domain/kegagalan.dart';
import '../domain/repositori_tugas.dart';
import '../domain/tugas.dart';
import 'sumber_tugas_memori.dart';

class RepositoriTugasMemori implements RepositoriTugas {
  RepositoriTugasMemori(this.sumber, {String Function()? jam})
    : _jam = jam ?? _tanggalSistem;

  final SumberTugasMemori sumber;

  final String Function() _jam;

  static const String kolomId = 'id';
  static const String kolomJudul = 'judul';
  static const String kolomMataKuliah = 'mata_kuliah';
  static const String kolomSelesai = 'selesai';
  static const String kolomDibuatPada = 'dibuat_pada';
  static const String kolomPrioritas = 'prioritas';

  static const String _mataKuliahCadangan = 'Umum';
  static const String _tanggalCadangan = '1970-01-01';
  static const int _prioritasCadangan = 2;

  static Tugas dariBaris(Map<String, Object?> baris) {
    final Object? selesaiMentah = baris[kolomSelesai];
    return Tugas(
      id: baris[kolomId] as String? ?? 'tanpa-id',
      judul: baris[kolomJudul] as String? ?? 'Tanpa Judul',
      mataKuliah: baris[kolomMataKuliah] as String? ?? _mataKuliahCadangan,
      selesai: selesaiMentah is bool
          ? selesaiMentah
          : (selesaiMentah is int && selesaiMentah == 1),
      dibuatPada: baris[kolomDibuatPada] as String? ?? _tanggalCadangan,
      prioritas: baris[kolomPrioritas] is int
          ? baris[kolomPrioritas] as int
          : _prioritasCadangan,
    );
  }

  static Map<String, Object?> keBaris(Tugas tugas) {
    return <String, Object?>{
      kolomId: tugas.id,
      kolomJudul: tugas.judul,
      kolomMataKuliah: tugas.mataKuliah,
      kolomSelesai: tugas.selesai ? 1 : 0,
      kolomDibuatPada: tugas.dibuatPada,
      kolomPrioritas: tugas.prioritas,
    };
  }

  Future<T> _jaga<T>(Future<T> Function() operasi) async {
    try {
      return await operasi();
    } on BarisTidakAda {
      rethrow; // Ditangani pemanggil: artinya berbeda per operasi.
    } on StateError {
      throw const SumberDataGagal();
    }
  }

  @override
  Future<List<Tugas>> muatSemua() async {
    final List<Map<String, Object?>> baris = await _jaga(sumber.ambilSemua);
    return baris.map(dariBaris).toList(growable: false);
  }

  @override
  Future<Tugas> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  }) async {
    final String bersih = judul.trim();
    if (bersih.isEmpty) {
      throw const JudulKosong();
    }

    final Map<String, Object?> baris = await _jaga(
      () => sumber.sisipkan(<String, Object?>{
        kolomJudul: bersih,
        kolomMataKuliah: mataKuliah.trim().isEmpty
            ? _mataKuliahCadangan
            : mataKuliah.trim(),
        kolomSelesai: 0,
        kolomDibuatPada: _jam(),
        kolomPrioritas: prioritas.clamp(1, 3),
      }),
    );

    return dariBaris(baris);
  }

  @override
  Future<void> ubahStatus(Tugas tugas) async {
    if (tugas.id.isEmpty || tugas.id == 'tanpa-id') {
      throw const TugasBelumTersimpan();
    }
    try {
      await sumber.perbaruiSelesai(tugas.id, !tugas.selesai);
    } on BarisTidakAda catch (e) {
      throw TugasTidakDitemukan(e.id);
    } on StateError {
      throw const SumberDataGagal();
    }
  }

  @override
  Future<void> hapus(String id) async {
    try {
      await sumber.hapus(id);
    } on BarisTidakAda catch (e) {
      throw TugasTidakDitemukan(e.id);
    } on StateError {
      throw const SumberDataGagal();
    }
  }

  static String _tanggalSistem() {
    final DateTime sekarang = DateTime.now();
    final String bulan = sekarang.month.toString().padLeft(2, '0');
    final String hari = sekarang.day.toString().padLeft(2, '0');
    return '${sekarang.year}-$bulan-$hari';
  }
}
