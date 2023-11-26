
import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/classes/sprite.dart';
import 'package:lemon_atlas/atlas/functions/build_src_rel_from_src_abs.dart';

import 'build_dst_from_src.dart';
import 'build_dst_image_from_src_image.dart';
import 'build_src_abs_from_atlas.dart';

Sprite buildSpriteFromImage({
  required Image srcImage,
  required int rows,
  required int columns,
}) {
  if (srcImage.format != Format.int8){
    srcImage = srcImage.convert(format: Format.int8);
  }
  final srcAbs = buildSrcAbsFromAtlas(rows, columns, srcImage);
  final dst = buildDstFromSrcAbs(srcAbs);

  final dstImage = buildDstImageFromSrcImage(
    srcAbs: srcAbs,
    dst: dst,
    srcImage: srcImage,
  );

  final spriteWidth = srcImage.width ~/ columns;
  final spriteHeight = srcImage.height ~/ rows;

  final srcRel = buildSrcRelFromSrcAbsolute(
    srcAbs: srcAbs,
    spriteWidth: spriteWidth,
    spriteHeight: spriteHeight,
  );

  return Sprite(
    spriteWidth: spriteWidth,
    spriteHeight: spriteHeight,
    rows: rows,
    columns: columns,
    image: dstImage,
    src: srcRel,
    dst: dst,
  );
}



