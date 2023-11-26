import 'dart:typed_data';

import 'package:image/image.dart';

import 'build_image_from_dst.dart';
import 'copy_paste.dart';

Image buildDstImageFromSrcImage({
  required Uint16List srcAbs,
  required Uint16List dst,
  required Image srcImage,
}) {

  final dstImage = buildImageFromDst(
      dst: dst,
      format: srcImage.format,
  );

  var i = 0;
  while (i < srcAbs.length){

    final srcLeft = srcAbs[i + 0];
    final srcTop = srcAbs[i + 1];
    final srcRight = srcAbs[i + 2];
    final srcBottom = srcAbs[i + 3];

    final dstLeft = dst[i + 0];
    final dstTop = dst[i + 1];

    final width = srcRight - srcLeft;
    final height = srcBottom - srcTop;

    copyPaste(
      srcImage: srcImage,
      dstImage: dstImage,
      width: width,
      height: height,
      srcX: srcLeft,
      srcY: srcTop,
      dstX: dstLeft,
      dstY: dstTop,
    );

    i += 4;
  }
  return dstImage;
}
