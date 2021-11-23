import 'dart:typed_data';

Float32List _dst = Float32List(4);

Float32List mapDst(
    {
      double scale = 1.0,
      double rotation = 0,
      double x,
      double y
    }){
  _dst[0] = scale;
  _dst[1] = rotation;
  _dst[2] = x;
  _dst[3] = y;
  return _dst;
}

