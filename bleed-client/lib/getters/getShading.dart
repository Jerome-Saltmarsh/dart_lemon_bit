
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/state/getTileAt.dart';

Shading getShading(double x, double y){
  int row = getRow(x, y);
  int column = getColumn(x, y);
  return render.dynamicShading[row][column];
}