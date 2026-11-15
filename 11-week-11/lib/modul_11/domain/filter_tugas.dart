import 'tugas_performa.dart';

class KriteriaFilter {
  const KriteriaFilter({this.kueri = '', this.status, this.mataKuliah});

  final String kueri;
  final StatusTugas? status;
  final String? mataKuliah;

  KriteriaFilter salinDengan({
    String? kueri,
    StatusTugas? status,
    String? mataKuliah,
    bool hapusStatus = false,
    bool hapusMataKuliah = false,
  }) {
    return KriteriaFilter(
      kueri: kueri ?? this.kueri,
      status: hapusStatus ? null : (status ?? this.status),
      mataKuliah: hapusMataKuliah ? null : (mataKuliah ?? this.mataKuliah),
    );
  }
}

List<TugasPerforma> saringTugas(
  List<TugasPerforma> sumber,
  KriteriaFilter kriteria,
) {
  final kataKunci = kriteria.kueri.trim().toLowerCase();

  return sumber.where((tugas) {
    final cocokKueri =
        kataKunci.isEmpty || tugas.kunciPencarian.contains(kataKunci);

    final cocokStatus =
        kriteria.status == null || tugas.status == kriteria.status;

    final cocokMataKuliah =
        kriteria.mataKuliah == null || tugas.mataKuliah == kriteria.mataKuliah;

    return cocokKueri && cocokStatus && cocokMataKuliah;
  }).toList();
}
