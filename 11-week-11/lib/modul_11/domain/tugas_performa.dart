/// Status sebuah tugas pada daftar Modul 11.
enum StatusTugas { aktif, selesai }

/// Model data satu tugas. Bersifat immutable.
class TugasPerforma {
  TugasPerforma({
    required this.nomor,
    required this.mataKuliah,
    required this.status,
  }) : kunciPencarian = '${_judulDari(nomor)} $mataKuliah'.toLowerCase();

  final int nomor;
  final String mataKuliah;
  final StatusTugas status;

  /// Dihitung sekali ketika objek dibuat.
  final String kunciPencarian;

  String get judul => _judulDari(nomor);

  bool get selesai => status == StatusTugas.selesai;

  static String _judulDari(int nomor) =>
      'Tugas praktikum ${nomor.toString().padLeft(4, '0')}';
}
