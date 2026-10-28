import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'penyimpanan_aman.dart';

class PenyimpananAmanPlatform implements PenyimpananAman {
  PenyimpananAmanPlatform() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> tulis(String kunci, String nilai) {
    return _storage.write(key: kunci, value: nilai);
  }

  @override
  Future<String?> baca(String kunci) {
    return _storage.read(key: kunci);
  }

  @override
  Future<void> hapus(String kunci) {
    return _storage.delete(key: kunci);
  }

  @override
  Future<String?> bacaMentah(String kunci) async {
    // Plugin tidak menyediakan pembacaan mentah melalui kontrak ini.
    return null;
  }
}
