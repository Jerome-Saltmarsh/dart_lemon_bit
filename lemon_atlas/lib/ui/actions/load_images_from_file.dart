import 'dart:io';

import 'package:image/image.dart';
import 'package:lemon_atlas/amulet/src.dart';
import 'package:lemon_atlas/atlas/functions/build_sprite_from_images.dart';
import 'package:lemon_atlas/atlas/functions/export_spritesheet.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

void loadImagesFromFileAndExport({
  required int rows,
  required int columns,
}) async {
  final files = await loadFilesFromDisk();
  if (files == null) {
    return;
  }
  final images = files
      .map((file) => decodeImage(file.bytes ?? (throw Exception())) ?? (throw Exception()))
      .toList(growable: false);

  final filePath = files.first.path ?? (throw Exception());
  final fileName = files.first.name;

  String directory;
  String name;

  if (filePath.contains(directoryRenders)) {
    final dir = filePath.replaceAll('\\$fileName', '');
    name = dir.split('\\').last;
    final up = dir.replaceAll(directoryRenders, '');
    final down = up.substring(0, up.length - name.length);
    directory = '$directorySprites/$down';
  } else {
    directory =  '${Directory.current.path}/assets/tmp';
    name = 'export';
  }

  exportSprite(
      sprite: buildSpriteFromSrcImages(
          srcImages: images,
          rows: rows,
          columns: columns,
      ),
      directory: directory,
      name: name,
  );
}
