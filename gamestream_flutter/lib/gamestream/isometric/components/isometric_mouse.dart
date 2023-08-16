

import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_component.dart';

class IsometricMouse with IsometricComponent {

  double get positionX => convertRenderToSceneX(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  double get positionY => convertRenderToSceneY(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  double get positionZ => player.position.z;
  double get playerAngle => angleBetween(player.position.x, player.position.y, positionX, positionY);
  double get playerDistance => distanceBetween(player.position.x, player.position.y, positionX, positionY);
  int get nodeIndex => scene.getIndexXYZ(positionX, positionY, positionZ);
  bool get inBounds => !scene.outOfBoundsXYZ(positionX, positionY, positionZ);
}