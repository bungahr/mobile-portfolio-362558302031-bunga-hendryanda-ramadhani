import '../domain/tugas_performa.dart';

const List<String> daftarMataKuliahContoh = <String>[
  'Pemrograman Mobile',
  'Basis Data',
  'Jaringan Komputer',
  'Rekayasa Perangkat Lunak',
  'Sistem Operasi',
  'Kecerdasan Buatan',
  'Pemrograman Web',
  'Analisis dan Perancangan Sistem',
];

List<TugasPerforma> buatTugasContoh({int jumlah = 1000}) =>
    List<TugasPerforma>.generate(
      jumlah,
      (int index) => TugasPerforma(
        nomor: index + 1,
        mataKuliah:
            daftarMataKuliahContoh[index % daftarMataKuliahContoh.length],
        status: _selesai(index) ? StatusTugas.selesai : StatusTugas.aktif,
      ),
      growable: false,
    );

bool _selesai(int index) =>
    (index ~/ daftarMataKuliahContoh.length + index) % 4 == 3;
