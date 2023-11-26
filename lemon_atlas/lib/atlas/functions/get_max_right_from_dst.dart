
import 'dart:math';
import 'dart:typed_data';

int getMaxRightFromDst(Uint16List dst){
  var i = 0;
  var maxRight = 0;
  while (i < dst.length){
    final left = dst[i++];
    final top = dst[i++];
    final right = dst[i++];
    final bottom = dst[i++];
    maxRight = max(maxRight, right);
  }
  return maxRight;
}
