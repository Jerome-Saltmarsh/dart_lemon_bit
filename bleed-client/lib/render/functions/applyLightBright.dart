import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void applyLightBrightMedium(List<List<Shade>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade.Bright);
  applyShadeRing(shader, row, column, 1, Shade.Bright);
  applyShadeRing(shader, row, column, 2, Shade.Medium);
  applyShadeRing(shader, row, column, 3, Shade.Dark);
}

void applyLightBrightSmall(List<List<Shade>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade.Medium);
  applyShadeRing(shader, row, column, 1, Shade.Medium);
  applyShadeRing(shader, row, column, 2, Shade.Dark);
}
