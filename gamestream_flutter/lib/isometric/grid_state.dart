import 'dart:typed_data';

import 'package:bleed_common/library.dart';

import 'grid.dart';

const gridNodeInitialSize = 70 * 70 * 8;
var gridNodeTotal = gridNodeInitialSize;
var gridNodeColor = Int32List(gridNodeInitialSize);
var gridNodeTypes = Uint8List(gridNodeInitialSize);
var gridNodeOrientations = Uint8List(gridNodeInitialSize);
var gridNodeShade = Uint8List(gridNodeInitialSize);
var gridNodeBake = Uint8List(gridNodeInitialSize);
var gridNodeWind = Uint8List(gridNodeInitialSize);
var gridNodeVisible = List<bool>.generate(gridNodeInitialSize, (index) => false);
var gridNodeVariation = List<bool>.generate(gridNodeInitialSize, (index) => false);
var gridNodeEmpty = List<bool>.generate(gridNodeInitialSize, (index) => false);


void gridNodeShadeSet(int index, int shade){

  if (shade < 0) {
    shade = 0;
  } else
  if (shade > Shade.Pitch_Black){
    shade = Shade.Pitch_Black;

  }
  gridNodeShade[index] = shade;
}

int gridNodeIndexZRC(int z, int row, int column) {
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
  final index = gridNodeIndexZRC(z, row, column);
  if (gridNodeWind[index] >= windIndexStrong) return;
  gridNodeWind[index]++;
}

int gridNodeGetIndexXYZ(double x, double y, double z) =>
  gridNodeIndexZRC(
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
    gridNodeTypes[gridNodeXYZIndex(x, y, z)];

bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
     NodeType.isRainOrEmpty(gridNodeTypes[gridNodeIndexZRC(z, row, column)]);

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
    gridNodeTypes[gridNodeIndexZRC(z, row, column)];

int gridNodeXYZIndex(double x, double y, double z) =>
    gridNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
    );
