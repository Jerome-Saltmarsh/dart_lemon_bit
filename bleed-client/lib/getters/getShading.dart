
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/state/getTileAt.dart';

Shading getShadeAtPosition(double x, double y){
  return getShade(getRow(x, y), getColumn(x, y));
}

Shading getShade(int row, int column){
  return render.dynamicShading[row][column];
}