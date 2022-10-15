import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

import 'grid.dart';




int getNodeIndexBelow(int index){
  return index - nodesArea;
}

int getNodeTypeBelow(int index){
  if (index < nodesArea) return NodeType.Boundary;
  final indexBelow = index - nodesArea;
  if (indexBelow >= GameState.nodesTotal) return NodeType.Boundary;
  return GameState.nodesType[indexBelow];
}

void setNodeShade(int index, int shade){

  if (shade < 0) {
    shade = 0;
  } else
  if (shade > Shade.Pitch_Black){
    shade = Shade.Pitch_Black;

  }
  GameState.nodesShade[index] = shade;
}

int getNodeIndexZRC(int z, int row, int column) {
  assert (verifyInBoundZRC(z, row, column));
  return (z * nodesArea) + (row * nodesTotalColumns) + column;
}

/// a verification receives some data and returns true or false
/// a false verification means that the data is not valid
///
/// a check does not change any state
bool verifyInBoundZRC(int z, int row, int column){
  if (z < 0) return false;
  if (z >= nodesTotalZ) return false;
  if (row < 0) return false;
  if (row >= nodesTotalRows) return false;
  if (column < 0) return false;
  if (column >= nodesTotalColumns) return false;
  return true;
}

void gridNodeWindIncrement(int z, int row, int column){
  final index = getNodeIndexZRC(z, row, column);
  if (GameState.nodesWind[index] >= windIndexStrong) return;
  GameState.nodesWind[index]++;
}

int getGridNodeIndexV3(Vector3 vector3) =>
    getGridNodeIndexXYZ(
      vector3.x, vector3.y, vector3.z
    );

int getGridNodeIndexXYZ(double x, double y, double z) =>
  getNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
  );

int gridNodeXYZTypeSafe(double x, double y, double z) {
  if (x < 0) return NodeType.Boundary;
  if (y < 0) return NodeType.Boundary;
  if (z < 0) return NodeType.Boundary;
  if (x >= nodesLengthRow) return NodeType.Boundary;
  if (y >= nodesLengthColumn) return NodeType.Boundary;
  if (z >= nodesLengthZ) return NodeType.Boundary;
  return gridNodeXYZType(x, y, z);
}

int gridNodeXYZType(double x, double y, double z) =>
    GameState.nodesType[gridNodeXYZIndex(x, y, z)];

bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
     NodeType.isRainOrEmpty(GameState.nodesType[getNodeIndexZRC(z, row, column)]);

int gridNodeZRCTypeSafe(int z, int row, int column) {
  if (z < 0) return NodeType.Boundary;
  if (row < 0) return NodeType.Boundary;
  if (column < 0) return NodeType.Boundary;
  if (z >= nodesTotalZ) return NodeType.Boundary;
  if (row >= nodesTotalRows) return NodeType.Boundary;
  if (column >= nodesTotalColumns) return NodeType.Boundary;
  return gridNodeZRCType(z, row, column);
}

int gridNodeZRCType(int z, int row, int column) =>
    GameState.nodesType[getNodeIndexZRC(z, row, column)];

int gridNodeXYZIndex(double x, double y, double z) =>
    getNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
    );
