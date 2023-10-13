
import 'dart:math';
import 'dart:typed_data';

Uint16List buildDstFromSrcAbs(Uint16List srcAbs){
  final dst = Uint16List(srcAbs.length);

  var i = 0;
  var dstX = 0;
  var dstY = 0;
  var maxHeight = 0;

  while (i < srcAbs.length) {
    final srcLeft = srcAbs[i + 0];
    final srcTop = srcAbs[i + 1];
    final srcRight = srcAbs[i + 2];
    final srcBottom = srcAbs[i + 3];
    final width = srcRight - srcLeft;
    final height = srcBottom - srcTop;

    if (width < 0){
      throw Exception('buildDstFromSrcAbs - width < 0');
    }
    if (height < 0){
      throw Exception('buildDstFromSrcAbs - height < 0');
    }

    maxHeight = max(maxHeight, height);

    if (dstX + width >= 2048) {
      dstX = 0;
      dstY += maxHeight + 1;
      maxHeight = 0;
    }

    dst[i + 0] = dstX; // left
    dst[i + 1] = dstY; // top
    dst[i + 2] = dstX + width; // right
    dst[i + 3] = dstY + height; // bottom
    dstX += width + 1;
    i += 4;
  }

  return dst;
}
