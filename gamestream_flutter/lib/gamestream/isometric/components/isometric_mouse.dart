

import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricMouse {

  final Isometric isometric;

  IsometricMouse(this.isometric);

  double get positionX => convertWorldToGridX(isometric.engine.mouseWorldX, isometric.engine.mouseWorldY) + isometric.player.position.z;
  double get positionY => convertWorldToGridY(isometric.engine.mouseWorldX, isometric.engine.mouseWorldY) + isometric.player.position.z;
  double get positionZ => isometric.player.position.z;
  double get playerAngle => angleBetween(isometric.player.position.x, isometric.player.position.y, positionX, positionY);
  double get playerDistance => distanceBetween(isometric.player.position.x, isometric.player.position.y, positionX, positionY);
  int get nodeIndex => isometric.scene.getIndexXYZ(positionX, positionY, positionZ);
  bool get inBounds => !isometric.scene.outOfBoundsXYZ(positionX, positionY, positionZ);
}