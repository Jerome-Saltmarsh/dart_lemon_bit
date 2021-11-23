
import 'dart:typed_data';

Float32List _src = Float32List(4);

Float32List mapSrc({double left, double top, double right, double bottom}){
  _src[0] = left;
  _src[1] = top;
  _src[2] = right;
  _src[3] = bottom;
  return _src;
}