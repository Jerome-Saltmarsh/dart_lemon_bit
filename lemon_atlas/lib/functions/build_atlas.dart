

import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_dst_from_src.dart';

import 'build_image_from_src_and_dst.dart';
import 'build_src_from_atlas.dart';

class SpriteSheet {
  final int spriteWidth;
  final int spriteHeight;
  final int rows;
  final int columns;
  final Image image;
  final Uint16List src;
  final Uint16List dst;

  SpriteSheet({
    required this.spriteWidth,
    required this.spriteHeight,
    required this.rows,
    required this.columns,
    required this.image,
    required this.src,
    required this.dst,
  });
}

SpriteSheet buildSpriteSheet({
  required Image srcImage,
  required int rows,
  required int columns,
}) {
  if (srcImage.format != Format.int8){
    srcImage = srcImage.convert(format: Format.int8);
  }
  final src = buildSrcFromAtlas(rows, columns, srcImage);
  final dst = buildDstFromSrc(src);
  final dstImage = buildImageFromSrcAndDst(
      src: src,
      dst: dst,
      srcImage: srcImage,
  );

  return SpriteSheet(
    spriteWidth: srcImage.width ~/ columns,
    spriteHeight: srcImage.height ~/ rows,
    rows: rows,
    columns: columns,
    image: dstImage,
    src: src,
    dst: dst,
  );
}



