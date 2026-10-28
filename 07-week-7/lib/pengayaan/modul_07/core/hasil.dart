import '../../../modul_07/domain/kegagalan.dart';

sealed class Hasil<T> {
  const Hasil();

  bool get berhasil => this is Sukses<T>;

  T? get nilaiAtauNull => switch (this) {
    Sukses<T>(:final T nilai) => nilai,
    Gagal<T>() => null,
  };

  Kegagalan? get kegagalanAtauNull => switch (this) {
    Sukses<T>() => null,
    Gagal<T>(:final Kegagalan kegagalan) => kegagalan,
  };

  Hasil<R> peta<R>(R Function(T nilai) ubah) => switch (this) {
    Sukses<T>(:final T nilai) => Sukses<R>(ubah(nilai)),
    Gagal<T>(:final Kegagalan kegagalan) => Gagal<R>(kegagalan),
  };
}

final class Sukses<T> extends Hasil<T> {
  const Sukses(this.nilai);

  final T nilai;

  @override
  String toString() => 'Sukses($nilai)';
}

final class Gagal<T> extends Hasil<T> {
  const Gagal(this.kegagalan);

  final Kegagalan kegagalan;

  @override
  String toString() => 'Gagal(${kegagalan.pesan})';
}
