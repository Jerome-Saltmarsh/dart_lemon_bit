import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'load_files_from_disk.dart';

Future<Uint8List?> loadBytesFromFile() async {
  final files = await loadFilesFromDisk();
  return files?[0].bytes;
}

Future<Image?> loadImageFromFile() async {
  final files = await loadFilesFromDisk();
  if (files == null) {
    return null;
  }
  final file = files[0];
  final bytes = file.bytes;

  if (bytes == null) {
    throw Exception('bytes == null');
  }

  final decoder = findDecoderForData(bytes);
  final decoded = decoder?.decode(bytes);
  return decoded;

  // return decodeImage(bytes);
}
