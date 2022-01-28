import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void emitLightLow(List<List<int>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade_Medium);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Dark);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
}

void emitLightMedium(List<List<int>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Medium);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
  applyShadeRing(shader, row, column, 4, Shade_VeryDark);
}

void emitLightHigh(List<List<int>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);

  if (row >= shader.length){
    throw Exception();
  }
  if (column >= shader[0].length){
    throw Exception();
  }

  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Bright);
  applyShadeRing(shader, row, column, 2, Shade_Medium);
  applyShadeRing(shader, row, column, 3, Shade_Dark);
  applyShadeRing(shader, row, column, 4, Shade_VeryDark);
}

void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Dark);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
}

