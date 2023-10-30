

import 'package:gamestream_flutter/gamestream/isometric/classes/src.dart';
import 'package:gamestream_flutter/isometric/functions/get_render.dart';
import 'package:lemon_math/src.dart';
import 'isometric_component.dart';

class IsometricMouse with IsometricComponent {

  double get positionX => convertRenderToSceneX(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  double get positionY => convertRenderToSceneY(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  double get positionZ => player.position.z;

  double getRenderDistanceSquare(Position position) => getDistanceXY(
      position.renderX,
      position.renderY,
      engine.mouseWorldX,
      engine.mouseWorldY,
    );
}