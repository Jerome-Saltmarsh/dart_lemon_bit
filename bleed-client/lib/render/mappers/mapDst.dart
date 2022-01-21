import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';

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

Float32List dst(Vector2 vector2, {double scale = 1.0}){
  return mapDst(x: vector2.x, y: vector2.y, scale: scale);
}