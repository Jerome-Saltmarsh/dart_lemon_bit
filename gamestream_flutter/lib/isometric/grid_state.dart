import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

import 'grid.dart';

const nodesInitialSize = 70 * 70 * 8;
var nodesBake = Uint8List(nodesInitialSize);
var nodesColor = Int32List(nodesInitialSize);
var nodesOrientation = Uint8List(nodesInitialSize);
var nodesShade = Uint8List(nodesInitialSize);
var nodesTotal = nodesInitialSize;
var nodesType = Uint8List(nodesInitialSize);
var nodesVariation = List<bool>.generate(nodesInitialSize, (index) => false);
var nodesVisible = List<bool>.generate(nodesInitialSize, (index) => false);
var nodesWind = Uint8List(nodesInitialSize);

int getGridNodeIndexBelow(int index){
  return index - gridTotalArea;
}

void gridNodeShadeSet(int index, int shade){

  if (shade < 0) {
    shade = 0;
  } else
  if (shade > Shade.Pitch_Black){
    shade = Shade.Pitch_Black;

  }
  nodesShade[index] = shade;
}

int getGridNodeIndexZRC(int z, int row, int column) {
  assert (gridNodeIsInBounds(z, row, column));

  return (z * gridTotalArea) + (row * gridTotalColumns) + column;
}

bool gridNodeIsInBounds(int z, int row, int column){
  if (z < 0) return false;
  if (z >= gridTotalZ) return false;
  if (row < 0) return false;
  if (row >= gridTotalRows) return false;
  if (column < 0) return false;
  if (column >= gridTotalColumns) return false;
  return true;
}

void gridNodeWindIncrement(int z, int row, int column){
  final index = getGridNodeIndexZRC(z, row, column);
  if (nodesWind[index] >= windIndexStrong) return;
  nodesWind[index]++;
}

int getGridNodeIndexV3(Vector3 vector3) =>
    getGridNodeIndexXYZ(
      vector3.x, vector3.y, vector3.z
    );

int getGridNodeIndexXYZ(double x, double y, double z) =>
  getGridNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
  );

int gridNodeXYZTypeSafe(double x, double y, double z) {
  if (x < 0) return NodeType.Boundary;
  if (y < 0) return NodeType.Boundary;
  if (z < 0) return NodeType.Boundary;
  if (x >= gridRowLength) return NodeType.Boundary;
  if (y >= gridColumnLength) return NodeType.Boundary;
  if (z >= gridZLength) return NodeType.Boundary;
  return gridNodeXYZType(x, y, z);
}

int gridNodeXYZType(double x, double y, double z) =>
    nodesType[gridNodeXYZIndex(x, y, z)];

bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
     NodeType.isRainOrEmpty(nodesType[getGridNodeIndexZRC(z, row, column)]);

int gridNodeZRCTypeSafe(int z, int row, int column) {
  if (z < 0) return NodeType.Boundary;
  if (row < 0) return NodeType.Boundary;
  if (column < 0) return NodeType.Boundary;
  if (z >= gridTotalZ) return NodeType.Boundary;
  if (row >= gridTotalRows) return NodeType.Boundary;
  if (column >= gridTotalColumns) return NodeType.Boundary;
  return gridNodeZRCType(z, row, column);
}

int gridNodeZRCType(int z, int row, int column) =>
    nodesType[getGridNodeIndexZRC(z, row, column)];

int gridNodeXYZIndex(double x, double y, double z) =>
    getGridNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
    );
