
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/modules/modules.dart';

int getShadeAtPosition(double x, double y){
  return getShade(getRow(x, y), getColumn(x, y));
}

int getShade(int row, int column){
  if (row < 0) return Shade_VeryDark;
  if (column < 0) return Shade_VeryDark;
  if (row >= modules.isometric.state.totalRows.value){
    return Shade_VeryDark;
  }
  if (column >= modules.isometric.state.totalColumns.value){
    return Shade_VeryDark;
  }
  return modules.isometric.state.dynamicShading[row][column];
}