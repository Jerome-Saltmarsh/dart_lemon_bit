
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/state/game.dart';

Shading getShadeAtPosition(double x, double y){
  return getShade(getRow(x, y), getColumn(x, y));
}

Shading getShade(int row, int column){
  // assert(row < game.totalRows);
  if (row >= game.totalRows){
    throw Exception();
  }
  if (column >= game.totalColumns){
    throw Exception();
  }

  // assert(column < game.totalColumns);
  return dynamicShading[row][column];
}