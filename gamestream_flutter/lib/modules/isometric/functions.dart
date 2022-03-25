import 'dart:math';

import 'package:bleed_common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/modules.dart';
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

final _timeline = core.state.timeline;

void srcLoopSimple({required double x, required int frames, required double size}){
  final frame = _timeline.frame % frames;
  engine.mapSrc(
      x: x,
      y: (frame * size),
      width: size,
      height: size
  );
}

void srcLoop({
  required Vector2 atlas,
  required int direction,
  required int column,
  int row = 0,
  double size = 64,
  int framesPerDirection = 4,
}){
  final _s = direction * size * framesPerDirection;
  final _f = (column % framesPerDirection) * size;
  engine.mapSrc(
      x: atlas.x + _s + _f,
      y: atlas.y + (row * size),
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