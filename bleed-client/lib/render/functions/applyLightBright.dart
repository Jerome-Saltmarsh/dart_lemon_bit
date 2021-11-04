import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/render/functions/applyLightArea.dart';

void applyLightBright(List<List<Shading>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyLightArea(shader, column, row, 7, Shading.Dark);
  applyLightArea(shader, column, row, 4, Shading.Medium);
  applyLightArea(shader, column, row, 2, Shading.Bright);
}
