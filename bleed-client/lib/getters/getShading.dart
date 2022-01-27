
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/modules/modules.dart';

Shade getShadeAtPosition(double x, double y){
  return getShade(getRow(x, y), getColumn(x, y));
}

Shade getShade(int row, int column){
  if (row < 0) return Shade.VeryDark;
  if (column < 0) return Shade.VeryDark;
  if (row >= modules.isometric.state.totalRows){
    return Shade.VeryDark;
  }
  if (column >= modules.isometric.state.totalColumns){
    return Shade.VeryDark;
  }
  return modules.isometric.state.dynamicShading[row][column];
}