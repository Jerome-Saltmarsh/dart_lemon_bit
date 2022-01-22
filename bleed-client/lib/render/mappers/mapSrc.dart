import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';

final Float32List _src = Float32List(4);

Float32List mapSrc({
  required double x,
  required double y,
  double width = 64,
  double height = 64
}){
  _src[0] = x;
  _src[1] = y;
  _src[2] = x + width;
  _src[3] = y + height;
  return _src;
}

Float32List buildSrc(Vector2 vector2, {double size = 64}){
  return mapSrc(x: vector2.x, y: vector2.y, width: size, height: size);
}

