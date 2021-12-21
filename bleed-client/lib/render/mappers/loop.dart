import 'dart:typed_data';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_engine/classes/vector2.dart';

final Float32List _src = Float32List(4);

Float32List loop({
  Vector2 atlas,
  Direction direction,
  int frame,
  Shade shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  double _s = direction.index * size * framesPerDirection;
  double _f = (frame % framesPerDirection) * size;
  _src[0] =  atlas.x + _s + _f;
  _src[1] = atlas.y + (shade.index * size);
  _src[2] = _src[0] + size;
  _src[3] = _src[1] + size;
  return _src;
}