import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_write_as_bytes_compat/file_write_as_bytes_compat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('write', () async {
    final file = File('build/test.txt');
    for (var i = 0; i < 100; ++i) {
      if (file.existsSync()) {
        file.deleteSync();
      }
      await file.writeAsBytesCompat(
        Uint8List.fromList(utf8.encode('ABCD')),
      );
      expect(utf8.decode(await file.readAsBytes()), 'ABCD');
    }
  });
}
