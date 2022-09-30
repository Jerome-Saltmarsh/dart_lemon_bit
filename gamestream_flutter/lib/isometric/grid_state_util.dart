


import 'package:gamestream_flutter/isometric/classes/vector3.dart';

import 'grid_state.dart';

int gridNodeShadeAtVector3(Vector3 vector3) =>
  gridNodeShade[gridNodeIndexVector3(vector3)];

int gridNodeTypeAtVector3(Vector3 vector3) =>
    gridNodeTypes[gridNodeIndexVector3(vector3)];

int gridNodeIndexVector3(Vector3 vector3) =>
  gridNodeIndexZRC(
    vector3.indexZ,
    vector3.indexRow,
    vector3.indexColumn,
  );

int gridNodeIndexVector3NodeBelow(Vector3 vector3) =>
    gridNodeIndexZRC(
      vector3.indexZ - 1,
      vector3.indexRow,
      vector3.indexColumn,
    );

bool gridNodeInBoundsVector3(Vector3 vector3) =>
    gridNodeIsInBounds(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

void gridNodeIncrementWindVector3(Vector3 vector3) =>
  gridNodeWindIncrement(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

int gridNodeWindGetVector3(Vector3 vector3) =>
  gridNodeWind[gridNodeIndexVector3(vector3)];