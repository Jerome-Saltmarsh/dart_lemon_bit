import 'dart:typed_data';

import 'package:bleed_common/library.dart';

import 'grid.dart';

var gridNodeTypes = Uint8List(0);
var gridNodeOrientations = Uint8List(0);
var gridNodeShade = Uint8List(0);
var gridNodeBake = Uint8List(0);
var gridNodeWind = Uint8List(0);
var gridNodeVisible = <bool>[];
var gridNodeTotal = 0;

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
  return (z * gridTotalRows * gridTotalColumns) + (row * gridTotalColumns) + column;
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

bool gridNodeZRCTypeEmpty(int z, int row, int column) =>
    gridNodeTypes[gridNodeIndexZRC(z, row, column)] == NodeType.Empty;

int gridNodeZRCType(int z, int row, int column) =>
    gridNodeTypes[gridNodeIndexZRC(z, row, column)];

int gridNodeXYZIndex(double x, double y, double z) =>
    gridNodeIndexZRC(
      z ~/ tileSizeHalf,
      x ~/ tileSize,
      y ~/ tileSize,
    );
