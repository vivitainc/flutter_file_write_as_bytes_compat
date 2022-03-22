

[![Github Actions](https://github.com/vivitainc/flutter_file_write_as_bytes_compat/actions/workflows/flutter-package-test.yaml/badge.svg)](https://github.com/vivitainc/flutter_file_write_as_bytes_compat/actions/workflows/flutter-package-test.yaml)

## Features

File.writeAsBytesが正常に書き込まれない不具合のWorkaround.

https://github.com/dart-lang/sdk/issues/36087

## Usage

```dart
final file = File('path/to/file');
file.writeAsBytes(bytes);       // Not Working Bug!!
file.writeAsBytesCompat(bytes); // Workaround.
```
