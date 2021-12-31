import 'dart:typed_data';

final Float32List _src = Float32List(4);

Float32List mapSrc({
  required double x,
  required double y,
  required double width,
  required double height
}){
  _src[0] = x;
  _src[1] = y;
  _src[2] = x + width;
  _src[3] = y + height;
  return _src;
}

