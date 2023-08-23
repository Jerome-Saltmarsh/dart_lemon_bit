
import 'dart:math';
import 'dart:typed_data';

Uint16List buildDstFromSrc(Uint16List src){
  final dst = Uint16List(src.length ~/ 4 * 6);

  var iSrc = 0;
  var iDst = 0;

  var dstX = 0;
  var dstY = 0;
  var maxHeight = 0;

  while (iSrc < src.length){
    final left = src[iSrc++];
    final top = src[iSrc++];
    final right = src[iSrc++];
    final bottom = src[iSrc++];
    final width = right - left;
    final height = bottom - top;
    maxHeight = max(maxHeight, height);

    if (dstX + width >= 2048) {
      dstX = 0;
      dstY += maxHeight + 1;
      maxHeight = 0;
    }

    dst[iDst++] = dstX; // left
    dst[iDst++] = dstY; // top
    dst[iDst++] = dstX + width; // right
    dst[iDst++] = dstY + height; // bottom
    dst[iDst++] = left; // dstX
    dst[iDst++] = top;  // dstY

    dstX += width + 1;
  }

  return dst;
}
