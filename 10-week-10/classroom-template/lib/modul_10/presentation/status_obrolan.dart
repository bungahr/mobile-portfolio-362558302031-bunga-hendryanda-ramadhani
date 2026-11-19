import '../domain/galat_ai.dart';
import '../domain/pesan_ai.dart';

/// Keadaan percakapan.
///
/// Satu nilai menggantikan beberapa variabel terpisah, sehingga keadaan yang
/// mustahil tidak dapat terjadi. Pola ini sama dengan yang dipakai pada Modul
/// 04 sampai Modul 07; yang berubah hanya jenis datanya.
sealed class StatusObrolan {
  const StatusObrolan();
}

/// Belum ada percakapan.
class ObrolanKosong extends StatusObrolan {
  const ObrolanKosong();
}

/// Permintaan sudah dikirim; jawaban belum mulai datang.
class ObrolanMenunggu extends StatusObrolan {
  const ObrolanMenunggu();
}

/// Jawaban sedang datang bertahap.
class ObrolanMengalir extends StatusObrolan {
  const ObrolanMengalir(this.pesan);

  /// Pesan asisten yang sedang tumbuh.
  final PesanAi pesan;
}

/// Percakapan selesai.
class ObrolanSiap extends StatusObrolan {
  const ObrolanSiap(this.pesan);

  /// Seluruh pesan yang sudah terjadi.
  final List<PesanAi> pesan;
}

/// Permintaan gagal.
class ObrolanGagal extends StatusObrolan {
  const ObrolanGagal(this.galat, this.pesan);

  /// Sebab kegagalan beserta pesan yang layak ditampilkan.
  final GalatAi galat;

  /// Pesan yang sudah terjadi sebelum kegagalan.
  final List<PesanAi> pesan;
}
