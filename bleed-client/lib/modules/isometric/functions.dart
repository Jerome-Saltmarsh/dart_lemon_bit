import 'dart:math';

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

void srcAnimate({
  required Vector2 atlas,
  required List<int> animation,
  required int direction,
  required int frame,
  int shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  final int animationFrame = min(frame, animation.length - 1);
  final double _s = direction * size * framesPerDirection;
  final double _f = (animation[animationFrame] % framesPerDirection) * size;
  engine.mapSrc(
    x: atlas.x + _s + _f,
    y: atlas.y + (shade * size),
    width: size,
    height: size,
  );
}


void srcLoop({
  required Vector2 atlas,
  required int direction,
  required int frame,
  int shade = Shade.Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  final _s = direction * size * framesPerDirection;
  final _f = (frame % framesPerDirection) * size;
  engine.mapSrc(
      x: atlas.x + _s + _f,
      y: atlas.y + (shade * size),
      width: size,
      height: size
  );
}

void srcSingle({
  required Vector2 atlas,
  required int direction,
  int column = 0,
  double size = 64,
}){
  engine.mapSrc(
      x: atlas.x + (direction * size),
      y: atlas.y + (column * size),
      width: size,
      height: size);
}