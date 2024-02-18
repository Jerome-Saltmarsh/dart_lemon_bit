
import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/classes/sprite.dart';
import 'package:lemon_atlas/atlas/functions/build_dst_image_from_src_images.dart';

import 'build_dst_from_src.dart';
import 'build_src.dart';
import 'build_src_rel_from_src_abs.dart';


Sprite buildSpriteFromSrcImages({
  required List<Image> srcImages,
  required int rows,
  required int columns,
}){

  if (srcImages.isEmpty) {
    throw Exception();
  }

  final srcAbs = buildSrcAbsFromImages(
      images: srcImages,
      rows: rows,
      columns: columns,
  );
  final dst = buildDstFromSrcAbs(srcAbs);

  final dstImage = buildDstImageFromSrcImages(
    srcImages: srcImages,
    srcAbs: srcAbs,
    dst: dst,
  );

  if (dstImage.isEmpty){
    throw Exception('dstImage.isEmpty');
  }

  final spriteWidth = srcImages.first.width;
  final spriteHeight = srcImages.first.height;

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