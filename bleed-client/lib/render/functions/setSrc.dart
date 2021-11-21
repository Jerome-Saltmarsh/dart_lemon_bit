
import 'dart:typed_data';

void setSrc(Float32List src, {int index = 0, double left, double top, double right, double bottom}){
  src[index] = left;
  src[index + 1] = top;
  src[index + 2] = right;
  src[index + 3] = bottom;
}