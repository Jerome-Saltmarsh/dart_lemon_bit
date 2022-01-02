import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:lemon_math/Vector2.dart';

Float32List animate({
  required Vector2 atlas,
  required List<int> animation,
  required Direction direction,
  required int frame,
  Shade shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  final int animationFrame = min(frame, animation.length - 1);
  final double _s = direction.index * size * framesPerDirection;
  final double _f = (animation[animationFrame] % framesPerDirection) * size;
  return mapSrc(
      x: atlas.x + _s + _f,
      y: atlas.y + (shade.index * size),
      width: size,
      height: size,
  );
}
