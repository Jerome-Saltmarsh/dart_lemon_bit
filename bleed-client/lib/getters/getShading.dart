
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/state/game.dart';

Shading getShadeAtPosition(double x, double y){
  return getShade(getRow(x, y), getColumn(x, y));
}

Shading getShade(int row, int column){
  if (row >= game.totalRows){
    return Shading.VeryDark;
  }
  if (column >= game.totalColumns){
    return Shading.VeryDark;
  }
  return dynamicShading[row][column];
}