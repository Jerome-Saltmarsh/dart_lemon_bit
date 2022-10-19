import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';


int getNodeIndexBelow(int index){
  return index - Game.nodesArea;
}

int getNodeTypeBelow(int index){
  if (index < Game.nodesArea) return NodeType.Boundary;
  final indexBelow = index - Game.nodesArea;
  if (indexBelow >= Game.nodesTotal) return NodeType.Boundary;
  return Game.nodesType[indexBelow];
}

// void setNodeShade(int index, int shade){
//   if (shade < 0) {
//     Game.nodesShade[index] = 0;
//     return;
//   }
//   if (shade > Shade.Pitch_Black){
//     Game.nodesShade[index] = Shade.Pitch_Black;
//     return;
//   }
//   Game.nodesShade[index] = shade;
// }

// int getNodeIndexZRC(int z, int row, int column) {
//   assert (verifyInBoundZRC(z, row, column));
//   return (z * Game.nodesArea) + (row * Game.nodesTotalColumns) + column;
// }

// int getNodeIndexV3(Vector3 v3) {
//   return Game.getNodeIndexZRC(v3.indexZ, v3.indexRow, v3.indexColumn);
// }

/// a verification receives some data and returns true or false
/// a false verification means that the data is not valid
///
/// a check does not change any state
bool verifyInBoundZRC(int z, int row, int column){
  if (z < 0) return false;
  if (z >= Game.nodesTotalZ) return false;
  if (row < 0) return false;
  if (row >= Game.nodesTotalRows) return false;
  if (column < 0) return false;
  if (column >= Game.nodesTotalColumns) return false;
  return true;
}

void gridNodeWindIncrement(int z, int row, int column){
  final index = Game.getNodeIndexZRC(z, row, column);
  if (Game.nodesWind[index] >= windIndexStrong) return;
  Game.nodesWind[index]++;
}

int getGridNodeIndexV3(Vector3 vector3) =>
    getGridNodeIndexXYZ(
      vector3.x, vector3.y, vector3.z
    );

int getGridNodeIndexXYZ(double x, double y, double z) =>
    Game.getNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
  );

int gridNodeXYZTypeSafe(double x, double y, double z) {
  if (x < 0) return NodeType.Boundary;
  if (y < 0) return NodeType.Boundary;
  if (z < 0) return NodeType.Boundary;
  if (x >= Game.nodesLengthRow) return NodeType.Boundary;
  if (y >= Game.nodesLengthColumn) return NodeType.Boundary;
  if (z >= Game.nodesLengthZ) return NodeType.Boundary;
  return gridNodeXYZType(x, y, z);
}

int gridNodeXYZType(double x, double y, double z) =>
    Game.nodesType[gridNodeXYZIndex(x, y, z)];

bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
     NodeType.isRainOrEmpty(Game.nodesType[Game.getNodeIndexZRC(z, row, column)]);

int gridNodeZRCTypeSafe(int z, int row, int column) {
  if (z < 0) return NodeType.Boundary;
  if (row < 0) return NodeType.Boundary;
  if (column < 0) return NodeType.Boundary;
  if (z >= Game.nodesTotalZ) return NodeType.Boundary;
  if (row >= Game.nodesTotalRows) return NodeType.Boundary;
  if (column >= Game.nodesTotalColumns) return NodeType.Boundary;
  return gridNodeZRCType(z, row, column);
}

int gridNodeZRCType(int z, int row, int column) =>
    Game.nodesType[Game.getNodeIndexZRC(z, row, column)];


int gridNodeXYZIndex(double x, double y, double z) =>
    Game.getNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
    );
