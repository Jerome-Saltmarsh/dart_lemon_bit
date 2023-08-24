
import 'package:image/image.dart';
import 'package:lemon_atlas/amulet/src.dart';
import 'package:lemon_atlas/atlas/functions/build_sprite_from_image.dart';
import 'package:lemon_atlas/atlas/functions/export_spritesheet.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

void loadImagesConvertToSpriteAndExportToFile({
  required int rows,
  required int columns,
}) async {
  final file = await loadFileFromDisk();

  if (file == null) {
    return;
  }

  final fileBytes = file.bytes;
  if (fileBytes == null){
    throw Exception();
  }

  final spriteSheet = buildSpriteFromImage(
      srcImage: decodePng(fileBytes) ?? (throw Exception()),
      rows: rows,
      columns: columns,
  );

  exportSprite(
      sprite: spriteSheet,
      directory: directoryTmp,
      name: file.name.replaceAll('.png', ''),
  );
}