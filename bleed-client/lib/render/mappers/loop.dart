import 'dart:typed_data';

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:lemon_math/Vector2.dart';

Float32List loop({
  required Vector2 atlas,
  required Direction direction,
  required int frame,
  Shade shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  final double _s = direction.index * size * framesPerDirection;
  final double _f = (frame % framesPerDirection) * size;
  return mapSrc(
      x: atlas.x + _s + _f,
      y: atlas.y + (shade.index * size),
      width: size,
      height: size);
}

Float32List single({
  required Vector2 atlas,
  required Direction direction,
  Shade shade = Shade.Bright,
  double size = 64,
}){
  return mapSrc(
      x: atlas.x + direction.index * size,
      y: atlas.y + (shade.index * size),
      width: size,
      height: size);
}