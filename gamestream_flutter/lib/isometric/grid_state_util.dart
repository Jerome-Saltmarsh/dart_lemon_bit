


import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';



bool inBoundsVector3(Vector3 vector3){
  if (vector3.x < 0) return false;
  if (vector3.y < 0) return false;
  if (vector3.z < 0) return false;
  if (vector3.x >= GameState.nodesLengthRow) return false;
  if (vector3.y >= GameState.nodesLengthColumn) return false;
  if (vector3.z >= GameState.nodesLengthZ) return false;
  return true;
}

int gridNodeShadeAtVector3(Vector3 vector3) =>
    GameState.nodesShade[gridNodeIndexVector3(vector3)];

int gridNodeTypeAtVector3(Vector3 vector3) =>
    gridNodeInBoundsVector3(vector3)
        ? GameState.nodesType[gridNodeIndexVector3(vector3)]
        : NodeType.Boundary;

int gridNodeIndexVector3(Vector3 vector3) =>
    GameState.getNodeIndexZRC(
    vector3.indexZ,
    vector3.indexRow,
    vector3.indexColumn,
  );

int gridNodeIndexVector3NodeBelow(Vector3 vector3) =>
    GameState.getNodeIndexZRC(
      vector3.indexZ - 1,
      vector3.indexRow,
      vector3.indexColumn,
    );

bool gridNodeInBoundsVector3(Vector3 vector3) =>
    GameQueries.isInboundZRC(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

int gridNodeWindGetVector3(Vector3 vector3) =>
    GameState.nodesWind[gridNodeIndexVector3(vector3)];
