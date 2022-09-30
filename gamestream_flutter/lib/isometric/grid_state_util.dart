


import 'package:gamestream_flutter/isometric/classes/vector3.dart';

import 'grid_state.dart';

int gridNodeIndexVector3(Vector3 vector3) =>
  gridNodeGetIndex(
    vector3.indexZ,
    vector3.indexRow,
    vector3.indexColumn,
  );

bool gridNodeInBoundsVector3(Vector3 vector3) =>
    gridNodeIsInBounds(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

void gridNodeIncrementWindVector3(Vector3 vector3) =>
  gridNodeWindIncrement(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

int gridNodeWindGetVector3(Vector3 vector3) =>
  gridNodeWind[gridNodeIndexVector3(vector3)];