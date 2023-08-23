
import 'dart:math';
import 'dart:typed_data';

int getTotalWidthFromDst(Uint16List dst){
  var i = 0;
  var maxWidth = 0;
  while (i < dst.length){
    final left = dst[i++];
    final top = dst[i++];
    final right = dst[i++];
    final bottom = dst[i++];
    final dstX = dst[i++];
    final dstY = dst[i++];
    maxWidth = max(maxWidth, right);
  }
  return maxWidth;
}
