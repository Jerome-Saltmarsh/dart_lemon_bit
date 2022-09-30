import 'dart:typed_data';

import 'grid.dart';

var gridNodeTypes = Uint8List(0);
var gridNodeOrientations = Uint8List(0);
var gridNodeShade = Uint8List(0);
var gridNodeBake = Uint8List(0);
var gridNodeWind = Uint8List(0);
var gridNodeVisible = <bool>[];

int get gridNodeTotal => gridNodeTypes.length;


int gridNodeGetIndex(int z, int row, int column) =>
    (z * gridTotalRows * gridTotalColumns) + (row * gridTotalColumns) + column;