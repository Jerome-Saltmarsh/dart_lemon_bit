
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:lemon_watch/src.dart';

class Sprite {

  final image = Watch<Uint8List?>(null);

  Future loadImage() async {
    image.value = await loadBytesFromFile();
  }

  Future<Uint8List?> loadBytesFromFile() async {
    final files = await loadFilesFromDisk();
    return files?[0].bytes;
  }

  Future<List<PlatformFile>?> loadFilesFromDisk() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      dialogTitle: 'Load Image',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    return result?.files;
  }
}