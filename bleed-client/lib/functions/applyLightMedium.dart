import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void applyLightMedium(List<List<Shade>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShade(shader, row, column, Shade.Medium);
  applyShadeRing(shader, row, column, 1, Shade.Medium);
  applyShadeRing(shader, row, column, 3, Shade.Dark);
}
