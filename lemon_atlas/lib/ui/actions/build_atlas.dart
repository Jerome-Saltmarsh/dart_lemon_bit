
import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_atlas.dart';
import 'package:lemon_atlas/functions/save_image_and_dst_to_file.dart';
import 'package:lemon_atlas/variables/tmp.dart';
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

  final spriteSheet = buildSpriteSheet(
      srcImage: decodePng(fileBytes) ?? (throw Exception()),
      rows: rows,
      columns: columns,
  );

  exportSpriteSheet(spriteSheet, tmp, file.name.replaceAll('.png', ''));
}