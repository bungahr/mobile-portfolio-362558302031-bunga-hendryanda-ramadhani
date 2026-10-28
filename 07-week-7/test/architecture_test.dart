
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ViewModel tidak mengimpor lapisan data', () {
    final folder = Directory('lib/modul_07/presentation');

    expect(folder.existsSync(), isTrue);

    for (final file in folder.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) {
        continue;
      }

      final isi = file.readAsStringSync();

      expect(
        RegExp(r'''import\s+['"][^'"]*/data/''').hasMatch(isi),
        isFalse,
        reason: '${file.path} tidak boleh mengimpor folder data secara langsung.',
      );
    }
  });
}
