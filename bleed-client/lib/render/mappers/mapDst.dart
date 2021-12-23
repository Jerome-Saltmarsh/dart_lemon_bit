import 'dart:typed_data';

final Float32List _dst = Float32List(4);

Float32List mapDst({
      required double x,
      required double y,
      double scale = 1.0,
      double rotation = 0,
}){
  _dst[0] = scale;
  _dst[1] = rotation;
  _dst[2] = x;
  _dst[3] = y;
  return _dst;
}

