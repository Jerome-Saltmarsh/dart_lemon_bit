

import 'package:amulet_flutter/gamestream/isometric/classes/src.dart';
import 'package:amulet_flutter/isometric/functions/get_render.dart';
import 'package:amulet_engine/packages/lemon_math.dart';
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