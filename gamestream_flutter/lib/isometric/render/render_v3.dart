import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:lemon_engine/engine.dart';

void renderV3({
  required Vector3 value,
  required double srcX,
  required double srcWidth,
  required double srcHeight,
  double srcY = 0,
}) =>
    Engine.renderBuffer(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: srcX,
      srcY: srcY,
      srcWidth: srcWidth,
      srcHeight: srcHeight,
      color: GameState.getV3NodeBelowShade(value),
    );
