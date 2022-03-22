import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

extension IoFileWriteAsBytesCompat on io.File {
  /// Dart SDKのFile書き込み不具合を避け、可能な限り確実にファイルを書き込む.
  ///
  /// 大容量ファイルの書き込みを分割チェックして行うため、適切な [blockSize] を指定する.
  ///
  /// NOTE.
  /// 書き込みの仕組み上、この処理は上書き保存のみをサポートする.
  /// 追記を確実に行いたい場合は別途確実性の高い手段を考えること.
  ///
  /// NOTE.
  /// 経験則として概ね1回目のリトライで書き込みは成功する.
  ///
  /// Dart SDK issue: https://github.com/dart-lang/sdk/issues/36087
  Future writeAsBytesCompat(
    Uint8List binary, {
    int blockSize = 1024 * 256,
    int retry = 10,
  }) async {
    Future<bool> writeImpl() async {
      // 既にファイルが存在していたら消す
      if (await exists()) {
        await delete();
      }
      var cursor = 0;
      try {
        final sink = await open(mode: io.FileMode.writeOnly);
        try {
          while (cursor < binary.length) {
            final length = min(blockSize, binary.length - cursor);
            await sink.writeFrom(binary, cursor, cursor + length);
            await Future<void>.delayed(const Duration(milliseconds: 1));
            await sink.flush();
            cursor += length;

            // ファイルの存在と長さをチェック
            if (!(await exists()) || (await this.length()) != cursor) {
              return false;
            }
          }
        } finally {
          await sink.close();
        }
      } on io.FileSystemException catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('FileExtensions.writeAsBytesCompat() failed: $e');
          debugPrint(stackTrace.toString());
        }
        return false;
      }
      return true;
    }

    // 失敗したのでリトライ
    for (var i = 0; i < (retry + 1); ++i) {
      if (await writeImpl()) {
        // 無事完了
        return;
      }
      debugPrint('Retry write[${i + 1}] -> $path');
    }
    throw io.FileSystemException('Write failed: $path');
  }
}
