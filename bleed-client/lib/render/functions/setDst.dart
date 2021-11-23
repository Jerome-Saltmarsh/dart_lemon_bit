import 'dart:typed_data';

Float32List _dst = Float32List(4);

Float32List mapDst(
    {
      int index = 0,
      double scale = 1,
      double rotation = 0,
      double x,
      double y
    }){
  _dst[index] = scale;
  _dst[index + 1] = rotation;
  _dst[index + 2] = x;
  _dst[index + 3] = y;
  return _dst;
}

