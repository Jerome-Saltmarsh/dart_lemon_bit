


import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

import 'nodes.dart';

bool isVisibleV3(Vector3 vector) =>
  inBoundsVector3(vector) ? nodesVisible[getGridNodeIndexV3(vector)] : true;

bool inBoundsVector3(Vector3 vector3){
  if (vector3.x < 0) return false;
  if (vector3.y < 0) return false;
  if (vector3.z < 0) return false;
  if (vector3.x >= nodesLengthRow) return false;
  if (vector3.y >= nodesLengthColumn) return false;
  if (vector3.z >= nodesLengthZ) return false;
  return true;
}

int gridNodeShadeAtVector3(Vector3 vector3) =>
  nodesShade[gridNodeIndexVector3(vector3)];

int gridNodeTypeAtVector3(Vector3 vector3) =>
    gridNodeInBoundsVector3(vector3)
        ? nodesType[gridNodeIndexVector3(vector3)]
        : NodeType.Boundary;

int gridNodeIndexVector3(Vector3 vector3) =>
  getNodeIndexZRC(
    vector3.indexZ,
    vector3.indexRow,
    vector3.indexColumn,
  );

int gridNodeIndexVector3NodeBelow(Vector3 vector3) =>
    getNodeIndexZRC(
      vector3.indexZ - 1,
      vector3.indexRow,
      vector3.indexColumn,
    );

bool gridNodeInBoundsVector3(Vector3 vector3) =>
    verifyInBoundZRC(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

void gridNodeIncrementWindVector3(Vector3 vector3) =>
  gridNodeWindIncrement(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

int gridNodeWindGetVector3(Vector3 vector3) =>
  nodesWind[gridNodeIndexVector3(vector3)];
