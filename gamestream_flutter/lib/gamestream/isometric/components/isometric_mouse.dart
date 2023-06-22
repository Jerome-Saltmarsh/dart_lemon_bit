

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';


class IsometricMouse {
  static IsometricPlayer get player => gamestream.isometric.player;

  static double get positionX => IsometricRender.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  static double get positionY => IsometricRender.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  static double get positionZ => player.position.z;
  static int get nodeIndex => gamestream.isometric.nodes.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(player.position.x, player.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(player.position.x, player.position.y, positionX, positionY);

  static bool get inBounds {
    return !gamestream.isometric.nodes.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}