
import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/functions/build_sprite.dart';
import 'package:lemon_atlas/atlas/functions/export_spritesheet.dart';
import 'package:lemon_atlas/atlas/variables/tmp.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

void buildAtlas({
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

  final spriteSheet = buildSprite(
      srcImage: decodePng(fileBytes) ?? (throw Exception()),
      rows: rows,
      columns: columns,
  );

  exportSprite(spriteSheet, tmp, file.name.replaceAll('.png', ''));
}