import 'package:gamestream_flutter/common/src/isometric/node_size.dart';

double getRenderX(double x, double y, double z) => (x - y) * 0.5;

double getRenderY(double x, double y, double z) => ((x + y) * 0.5) - z;

double getRenderXOfRowAndColumn(int row, int column) =>
(row - column) * Node_Size_Half;

double getRenderYfOfRowColumn(int row, int column) =>
(row + column) * Node_Size_Half;

double getRenderYOfRowColumnZ(int row, int column, int z) =>
(row + column - z) * Node_Size_Half;

double convertWorldToGridX(double x, double y) => x + y;

double convertWorldToGridY(double x, double y) => y - x;

int convertWorldToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;

int convertWorldToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;