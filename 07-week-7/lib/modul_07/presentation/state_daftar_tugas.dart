import '../domain/tugas.dart';

// Status pemuatan dan status kosong dipisahkan: daftar kosong tetap siap.
enum StatusMuat { awal, memuat, siap, gagal }

class StateDaftarTugas {
  const StateDaftarTugas({
    this.status = StatusMuat.awal,
    this.daftar = const <Tugas>[],
    this.pesanGagal,
  });

  final StatusMuat status;
  // final menjaga referensi, bukan isi List. ViewModel tidak memutasi daftar.
  final List<Tugas> daftar;

  final String? pesanGagal;

  bool get sedangMemuat => status == StatusMuat.memuat;

  bool get kosong => status == StatusMuat.siap && daftar.isEmpty;

  bool get adaGagal => status == StatusMuat.gagal;

  int get jumlahBelumSelesai => daftar.where((Tugas t) => !t.selesai).length;

  StateDaftarTugas salinDengan({
    StatusMuat? status,
    List<Tugas>? daftar,
    String? pesanGagal,
    bool hapusPesanGagal = false,
  }) {
    return StateDaftarTugas(
      status: status ?? this.status,
      daftar: daftar ?? this.daftar,
      pesanGagal: hapusPesanGagal ? null : (pesanGagal ?? this.pesanGagal),
    );
  }

  @override
  String toString() =>
      'StateDaftarTugas(${status.name}, ${daftar.length} item, pesanGagal: $pesanGagal)';
}
