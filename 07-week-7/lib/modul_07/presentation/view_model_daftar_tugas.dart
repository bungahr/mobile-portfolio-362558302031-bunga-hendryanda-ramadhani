import 'package:flutter/foundation.dart';

import '../domain/kegagalan.dart';
import '../domain/repositori_tugas.dart';
import '../domain/tugas.dart';
import 'state_daftar_tugas.dart';

class ViewModelDaftarTugas extends ChangeNotifier {
  ViewModelDaftarTugas(this.repositori);

  final RepositoriTugas repositori;

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
    // Operasi async dapat selesai setelah pemilik membuang ViewModel.
    if (_dibuang) return;
    _state = baru;
    jumlahPemberitahuan++;
    notifyListeners();
  }

  Future<void> muat() async {
    _ubah(const StateDaftarTugas(status: StatusMuat.memuat));
    try {
      final List<Tugas> daftar = await repositori.muatSemua();
      _ubah(StateDaftarTugas(status: StatusMuat.siap, daftar: daftar));
    } on Kegagalan catch (k) {
      _ubah(StateDaftarTugas(status: StatusMuat.gagal, pesanGagal: k.pesan));
    } catch (e) {
      debugPrint('Kegagalan tak terduga saat memuat: $e');
      _ubah(
        const StateDaftarTugas(
          status: StatusMuat.gagal,
          pesanGagal: 'Terjadi kesalahan tak terduga. Coba muat ulang.',
        ),
      );
    }
  }

  Future<bool> tambah({
    required String judul,
    required String mataKuliah,
    int prioritas = 2,
  }) async {
    try {
      await repositori.tambah(
        judul: judul,
        mataKuliah: mataKuliah,
        prioritas: prioritas,
      );
      await muat();
      return true;
    } on Kegagalan catch (k) {
      _ubah(_state.salinDengan(pesanGagal: k.pesan));
      return false;
    } catch (e) {
      debugPrint('Kegagalan tak terduga saat menambah: $e');
      _ubah(_state.salinDengan(pesanGagal: 'Tugas gagal disimpan. Coba lagi.'));
      return false;
    }
  }

  Future<bool> ubahStatus(Tugas tugas) async {
    try {
      await repositori.ubahStatus(tugas);
      await muat();
      return true;
    } on Kegagalan catch (k) {
      _ubah(_state.salinDengan(pesanGagal: k.pesan));
      return false;
    } catch (e) {
      debugPrint('Kegagalan tak terduga saat mengubah status: $e');
      _ubah(
        _state.salinDengan(pesanGagal: 'Status tugas gagal diubah. Coba lagi.'),
      );
      return false;
    }
  }

  Future<bool> hapus(String id) async {
    try {
      await repositori.hapus(id);
      await muat();
      return true;
    } on Kegagalan catch (k) {
      _ubah(_state.salinDengan(pesanGagal: k.pesan));
      return false;
    } catch (e) {
      debugPrint('Kegagalan tak terduga saat menghapus: $e');
      _ubah(_state.salinDengan(pesanGagal: 'Tugas gagal dihapus. Coba lagi.'));
      return false;
    }
  }

  void bersihkanPesanGagal() {
    if (_state.pesanGagal == null) return;
    _ubah(_state.salinDengan(hapusPesanGagal: true));
  }
}
