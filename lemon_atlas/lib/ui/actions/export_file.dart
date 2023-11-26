
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';
import 'package:lemon_atlas/amulet/variables/directory_tmp.dart';
import 'package:lemon_atlas/atlas/functions/build_sprite_from_image.dart';
import 'package:lemon_atlas/atlas/functions/export_spritesheet.dart';

String exportFile(List<PlatformFile> files, int rows, int columns) {
  final file = files.first;
  final fileBytes = file.bytes;
  if (fileBytes == null){
    throw Exception();
  }

  final srcImage = decodePng(fileBytes) ?? (throw Exception());

  final spriteSheet = buildSpriteFromImage(
    srcImage: srcImage,
    rows: rows,
    columns: columns,
  );

  return exportSprite(
    sprite: spriteSheet,
    directory: directoryTmp,
    name: file.name.replaceAll('.png', ''),
  );
}