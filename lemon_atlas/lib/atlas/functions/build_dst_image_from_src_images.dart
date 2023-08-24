
import 'dart:typed_data';

import 'package:image/image.dart';

import 'build_image_from_dst.dart';
import 'copy_paste.dart';

Image buildDstImageFromSrcImages({
  required List<Image> srcImages,
  required Uint16List srcAbs,
  required Uint16List dst,
}) {

  final dstImage = buildImageFromDst(dst: dst, format: srcImages.first.format);

  var i = 0;

  for (final srcImage in srcImages){

    final dstLeft = dst[i + 0];
    final dstTop = dst[i + 1];

    final srcLeft = srcAbs[i + 0];
    final srcTop = srcAbs[i + 1];
    final srcRight = srcAbs[i + 2];
    final srcBottom = srcAbs[i + 3];

    final renderWidth = srcRight - srcLeft;
    final renderHeight = srcBottom - srcTop;

    copyPaste(
      srcImage: srcImage,
      dstImage: dstImage,
      width: renderWidth,
      height: renderHeight,
      srcX: srcLeft,
      srcY: srcTop,
      dstX: dstLeft,
      dstY: dstTop,
    );

    i += 4;
  }

  return dstImage;
}