import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_math/Vector2.dart';

final Float32List _src = Float32List(4);

Float32List animate({
  required Vector2 atlas,
  required List<int> animation,
  required Direction direction,
  required int frame,
  Shade shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){

  int animationFrame = min(frame, animation.length - 1);
  int f = animation[animationFrame];
  double _s = direction.index * size * framesPerDirection;
  double _f = (f % framesPerDirection) * size;
  _src[0] =  atlas.x + _s + _f;
  _src[1] = atlas.y + (shade.index * size);
  _src[2] = _src[0] + size;
  _src[3] = _src[1] + size;
  return _src;
}
