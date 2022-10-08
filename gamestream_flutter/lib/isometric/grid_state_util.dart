


import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

import 'grid_state.dart';

int gridNodeShadeAtVector3(Vector3 vector3) =>
  nodesShade[gridNodeIndexVector3(vector3)];

int gridNodeTypeAtVector3(Vector3 vector3) =>
    gridNodeInBoundsVector3(vector3)
        ? nodesType[gridNodeIndexVector3(vector3)]
        : NodeType.Boundary;

int gridNodeIndexVector3(Vector3 vector3) =>
  getGridNodeIndexZRC(
    vector3.indexZ,
    vector3.indexRow,
    vector3.indexColumn,
  );

int gridNodeIndexVector3NodeBelow(Vector3 vector3) =>
    getGridNodeIndexZRC(
      vector3.indexZ - 1,
      vector3.indexRow,
      vector3.indexColumn,
    );

bool gridNodeInBoundsVector3(Vector3 vector3) =>
    gridNodeIsInBounds(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

void gridNodeIncrementWindVector3(Vector3 vector3) =>
  gridNodeWindIncrement(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

int gridNodeWindGetVector3(Vector3 vector3) =>
  nodesWind[gridNodeIndexVector3(vector3)];