import 'package:amulet_flutter/packages/common/src/isometric/node_size.dart';


double getRenderXOfRowAndColumn(int row, int column) =>
(row - column) * Node_Size_Half;

double getRenderYfOfRowColumn(int row, int column) =>
(row + column) * Node_Size_Half;

double getRenderYOfRowColumnZ(int row, int column, int z) =>
(row + column - z) * Node_Size_Half;

double getRenderX(double x, double y, double z) => (x - y) * 0.5;

double getRenderY(double x, double y, double z) => ((x + y) * 0.5) - z;

double convertRenderToSceneX(double x, double y) => x + y;

double convertRenderToSceneY(double x, double y) => y - x;

int convertRenderToRow(double x, double y, double z) => (x + y + z) ~/ Node_Size;

int convertRenderToColumn(double x, double y, double z) => (y - x + z) ~/ Node_Size;