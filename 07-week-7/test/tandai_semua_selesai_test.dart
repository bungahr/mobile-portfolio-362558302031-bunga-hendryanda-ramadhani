import 'package:flutter_test/flutter_test.dart';
import 'package:modul_07/modul_07/domain/kegagalan.dart';
import 'package:modul_07/modul_07/domain/repositori_tugas.dart';
import 'package:modul_07/modul_07/domain/tugas.dart';
import 'package:modul_07/pengayaan/modul_07/usecase/tandai_semua_selesai.dart';

class RepositoriPalsu implements RepositoriTugas {
  RepositoriPalsu(this.gagalPada);

  final Set<String> gagalPada;
  final List<Tugas> berhasilDisimpan = [];

  @override
  Future<List<Tugas>> muatSemua() async => berhasilDisimpan;

  @override
  Future<Tugas> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> ubahStatus(Tugas tugas) async {
    if (gagalPada.contains(tugas.id)) {
      throw const SumberDataGagal();
    }
    berhasilDisimpan.add(tugas);
  }

  @override
  Future<void> hapus(String id) async {
    throw UnimplementedError();
  }
}

Tugas buatTugas(String id, {bool selesai = false}) => Tugas(
  id: id,
  judul: 'Tugas $id',
  mataKuliah: 'TRPL',
  dibuatPada: '2026-10-28',
  selesai: selesai,
);

void main() {
  group('TandaiSemuaSelesai', () {
    test('memperbarui tugas yang belum selesai', () async {
      final repositori = RepositoriPalsu({});
      final useCase = TandaiSemuaSelesai(repositori);

      final hasil = await useCase.panggil([
        buatTugas('1'),
        buatTugas('2', selesai: true),
        buatTugas('3'),
      ]);

      expect(hasil.jumlahDiperbarui, 2);
      expect(hasil.kegagalan, isEmpty);
      expect(hasil.berhasilPenuh, isTrue);
      expect(repositori.berhasilDisimpan, hasLength(2));
      expect(repositori.berhasilDisimpan.every((t) => t.selesai), isTrue);
    });

    test('melaporkan hasil parsial jika sebagian operasi gagal', () async {
      final repositori = RepositoriPalsu({'2'});
      final useCase = TandaiSemuaSelesai(repositori);

      final hasil = await useCase.panggil([
        buatTugas('1'),
        buatTugas('2'),
        buatTugas('3'),
      ]);

      expect(hasil.jumlahDiperbarui, 2);
      expect(hasil.kegagalan, hasLength(1));
      expect(hasil.berhasilPenuh, isFalse);
    });
  });
}
