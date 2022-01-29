import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

void srcLoop({
  required Vector2 atlas,
  required Direction direction,
  required int frame,
  int shade = Shade_Bright,
  double size = 64,
  int framesPerDirection = 4,
}){
  final _s = direction.index * size * framesPerDirection;
  final _f = (frame % framesPerDirection) * size;
  engine.actions.mapSrc(
      x: atlas.x + _s + _f,
      y: atlas.y + (shade * size),
      width: size,
      height: size
  );
}

void srcSingle({
  required Vector2 atlas,
  required Direction direction,
  int shade = Shade_Bright,
  double size = 64,
}){
  engine.actions.mapSrc(
      x: atlas.x + (direction.index * size),
      y: atlas.y + (shade * size),
      width: size,
      height: size);
}