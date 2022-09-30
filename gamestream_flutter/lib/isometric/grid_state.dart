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

int gridNodeGetIndex(int z, int row, int column) {
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
  final index = gridNodeGetIndex(z, row, column);
  if (gridNodeWind[index] >= windIndexStrong) return;
  gridNodeWind[index]++;
}