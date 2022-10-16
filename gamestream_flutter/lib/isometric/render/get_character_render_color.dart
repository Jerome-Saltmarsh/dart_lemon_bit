import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

int getRenderShade(Vector3 vector3) =>
  getNodeBelowShade(vector3);

int getRenderColor(Vector3 vector3) =>
    Game.colorShades[getNodeBelowShade(vector3)];

int getNodeBelowShade(Vector3 vector3) =>
    Game.getNodeShade(vector3.indexZ - 1, vector3.indexRow, vector3.indexColumn);
