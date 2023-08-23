import 'dart:typed_data';

import 'package:image/image.dart';

import '../variables/transparent.dart';
import 'copy_paste.dart';
import 'get_max_height_from_dst.dart';
import 'get_total_width_from_dst.dart';

Image buildImageFromSrcAndDst({
  required Uint16List src,
  required Uint16List dst,
  required Image srcImage,
}) {
  final total = src.length ~/ 4;
  final dstWidth = getTotalWidthFromDst(dst);
  final dstHeight = getMaxHeightFromDst(dst);

  final dstImage = Image(
    width: dstWidth,
    height: dstHeight,
    numChannels: 4,
    backgroundColor: transparent,
  );

  for (var i = 0; i < total; i++){
    var iSrc = i * 4;
    final srcLeft = src[iSrc++];
    final srcTop = src[iSrc++];
    final srcRight = src[iSrc++];
    final srcBottom = src[iSrc++];

    final width = srcRight - srcLeft;
    final height = srcBottom - srcTop;

    var iDst = i * 6;
    final dstX = dst[iDst++];
    final dstY = dst[iDst++];

    copyPaste(
      srcImage: srcImage,
      dstImage: dstImage,
      width: width,
      height: height,
      srcX: srcLeft,
      srcY: srcTop,
      dstX: dstX,
      dstY: dstY,
    );
  }
  return dstImage;
}
