import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/functions/build_images.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

void loadImagesFromFile() async {
  final files = await loadFilesFromDisk();
  if (files == null) throw Exception();
  final images = files
      .map((file) => decodeImage(file.bytes ?? (throw Exception())) ?? (throw Exception()))
      .toList(growable: false);

  buildImages(
    images,
    rows: 1,
    columns: images.length,
    directory: '${Directory.current.path}/assets/tmp',
    name: 'export',
  );
}
