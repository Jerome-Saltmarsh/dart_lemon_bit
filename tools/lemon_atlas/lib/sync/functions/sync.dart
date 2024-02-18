
import 'package:lemon_atlas/sync/functions/load_images_from_directory.dart';
import 'package:lemon_atlas/atlas/functions/build_sprite_from_images.dart';
import 'package:lemon_atlas/atlas/functions/export_spritesheet.dart';

void sync({
  required String srcDir,
  required String targetDirectory,
  required String name,
  required int rows,
}) {
  final srcImages = loadImagesFomDirectory(srcDir);

  for (final image in srcImages){
    if (image.isEmpty){
      throw Exception('srcImages contains and empty image');
    }
  }

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: rows,
    columns: srcImages.length ~/ rows,
  );

  if (sprite.image.isEmpty){
    throw Exception('sprite is empty');
  }

  exportSprite(
    sprite: sprite,
    directory: targetDirectory,
    name: name,
  );
}