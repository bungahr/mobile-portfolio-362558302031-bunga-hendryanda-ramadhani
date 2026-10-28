import 'package:flutter/foundation.dart';

import '../../../modul_07/domain/tugas.dart';
import '../../../modul_07/presentation/state_daftar_tugas.dart';
import '../core/hasil.dart';
import '../usecase/hapus_tugas.dart';
import '../usecase/muat_daftar_tugas.dart';
import '../usecase/tambah_tugas.dart';
import '../usecase/ubah_status_tugas.dart';

class ViewModelTugasPengayaan extends ChangeNotifier {
  ViewModelTugasPengayaan({
    required this.muatDaftar,
    required this.tambahTugas,
    required this.ubahStatusTugas,
    required this.hapusTugas,
  });

  final MuatDaftarTugas muatDaftar;
  final TambahTugas tambahTugas;
  final UbahStatusTugas ubahStatusTugas;
  final HapusTugas hapusTugas;

  StateDaftarTugas _state = const StateDaftarTugas();

  StateDaftarTugas get state => _state;

  int jumlahPemberitahuan = 0;

  bool _dibuang = false;

  @override
  void dispose() {
    _dibuang = true;
    super.dispose();
  }

  void _ubah(StateDaftarTugas baru) {
    if (_dibuang) return;
    _state = baru;
    jumlahPemberitahuan++;
    notifyListeners();
  }

  Future<void> muat() async {
    _ubah(const StateDaftarTugas(status: StatusMuat.memuat));

    final Hasil<List<Tugas>> hasil = await muatDaftar.panggil();

    switch (hasil) {
      case Sukses<List<Tugas>>(:final List<Tugas> nilai):
        _ubah(StateDaftarTugas(status: StatusMuat.siap, daftar: nilai));
      case Gagal<List<Tugas>>(:final kegagalan):
        _ubah(
          StateDaftarTugas(
            status: StatusMuat.gagal,
            pesanGagal: kegagalan.pesan,
          ),
        );
    }
  }

  Future<bool> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  }) async {
    final Hasil<Tugas> hasil = await tambahTugas.panggil(
      MasukanTambahTugas(
        judul: judul,
        mataKuliah: mataKuliah,
        prioritas: prioritas,
      ),
    );

    switch (hasil) {
      case Sukses<Tugas>():
        await muat();
        return true;
      case Gagal<Tugas>(:final kegagalan):
        _ubah(_state.salinDengan(pesanGagal: kegagalan.pesan));
        return false;
    }
  }

  Future<bool> ubahStatus(Tugas tugas) async {
    final Hasil<void> hasil = await ubahStatusTugas.panggil(tugas);

    switch (hasil) {
      case Sukses<void>():
        await muat();
        return true;
      case Gagal<void>(:final kegagalan):
        _ubah(_state.salinDengan(pesanGagal: kegagalan.pesan));
        return false;
    }
  }

  Future<bool> hapus(String id) async {
    final Hasil<void> hasil = await hapusTugas.panggil(id);

    switch (hasil) {
      case Sukses<void>():
        await muat();
        return true;
      case Gagal<void>(:final kegagalan):
        _ubah(_state.salinDengan(pesanGagal: kegagalan.pesan));
        return false;
    }
  }

  void bersihkanPesanGagal() {
    if (_state.pesanGagal == null) return;
    _ubah(_state.salinDengan(hapusPesanGagal: true));
  }
}
