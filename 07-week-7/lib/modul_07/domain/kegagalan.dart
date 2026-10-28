sealed class Kegagalan implements Exception {
  const Kegagalan(this.pesan);

  final String pesan;

  @override
  String toString() => pesan;
}

final class JudulKosong extends Kegagalan {
  const JudulKosong() : super('Judul tugas tidak boleh kosong.');
}

final class TugasBelumTersimpan extends Kegagalan {
  const TugasBelumTersimpan()
    : super('Tugas ini belum tersimpan, jadi belum bisa diubah.');
}

final class TugasTidakDitemukan extends Kegagalan {
  const TugasTidakDitemukan(this.id)
    : super('Tugas tidak ditemukan. Silakan muat ulang daftar.');

  final String id;
}

final class SumberDataGagal extends Kegagalan {
  const SumberDataGagal([String? keterangan])
    : super(
        keterangan ??
            'Penyimpanan tidak bisa diakses. Coba lagi sebentar lagi.',
      );
}
