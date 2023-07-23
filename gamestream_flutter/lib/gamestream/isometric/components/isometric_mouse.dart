

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';


class IsometricMouse {
  static IsometricPlayer get player => gamestream.player;

  static double get positionX => IsometricRender.convertWorldToGridX(gamestream.engine.mouseWorldX, gamestream.engine.mouseWorldY) + player.position.z;
  static double get positionY => IsometricRender.convertWorldToGridY(gamestream.engine.mouseWorldX, gamestream.engine.mouseWorldY) + player.position.z;
  static double get positionZ => player.position.z;
  static int get nodeIndex => gamestream.getIndexXYZ(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(player.position.x, player.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(player.position.x, player.position.y, positionX, positionY);

  static bool get inBounds {
    return !gamestream.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}