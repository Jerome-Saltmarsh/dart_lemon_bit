import 'dart:async';
import 'dart:typed_data';

import 'load_files_from_disk.dart';

Future<Uint8List?> loadBytesFromFile() async {
  final files = await loadFilesFromDisk();
  return files?[0].bytes;
}


