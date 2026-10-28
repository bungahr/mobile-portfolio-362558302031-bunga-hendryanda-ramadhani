import 'package:get_it/get_it.dart';

import '../../../modul_07/data/repositori_tugas_memori.dart';
import '../../../modul_07/data/sumber_tugas_memori.dart';
import '../../../modul_07/domain/repositori_tugas.dart';
import '../presentation/view_model_tugas_pengayaan.dart';
import '../usecase/hapus_tugas.dart';
import '../usecase/muat_daftar_tugas.dart';
import '../usecase/tambah_tugas.dart';
import '../usecase/ubah_status_tugas.dart';

// Lokator milik contoh Modul 07, terpisah dari container global fitur lain.
final GetIt lokator = GetIt.asNewInstance();

Future<void> siapkanLokator({RepositoriTugas? repositori}) async {
  await lokator.reset();

  lokator.registerLazySingleton<RepositoriTugas>(
    () => repositori ?? RepositoriTugasMemori(SumberTugasMemori()),
  );

  lokator.registerLazySingleton<MuatDaftarTugas>(
    () => MuatDaftarTugas(lokator<RepositoriTugas>()),
  );
  lokator.registerLazySingleton<TambahTugas>(
    () => TambahTugas(lokator<RepositoriTugas>()),
  );
  lokator.registerLazySingleton<UbahStatusTugas>(
    () => UbahStatusTugas(lokator<RepositoriTugas>()),
  );
  lokator.registerLazySingleton<HapusTugas>(
    () => HapusTugas(lokator<RepositoriTugas>()),
  );

  lokator.registerFactory<ViewModelTugasPengayaan>(
    () => ViewModelTugasPengayaan(
      muatDaftar: lokator<MuatDaftarTugas>(),
      tambahTugas: lokator<TambahTugas>(),
      ubahStatusTugas: lokator<UbahStatusTugas>(),
      hapusTugas: lokator<HapusTugas>(),
    ),
  );
}

Future<void> bersihkanLokator() async {
  await lokator.reset();
}
