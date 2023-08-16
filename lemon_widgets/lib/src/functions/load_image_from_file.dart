import 'package:image/image.dart';

import 'load_files_from_disk.dart';

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
  return decodePng(bytes);
}