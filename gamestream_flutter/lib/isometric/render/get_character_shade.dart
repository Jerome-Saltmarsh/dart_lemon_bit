

import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

int getShadeV3(Vector3 vector3){
  return getNode(vector3.indexZ, vector3.indexRow, vector3.indexColumn).shade;
}