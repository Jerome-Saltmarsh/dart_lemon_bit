import 'dart:math';

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/getTileAt.dart';

void applyLightArea(List<List<Shading>> shader, double x, double y, int size, Shading shade) {
  int column = getColumn(x, y);
  int row = getRow(x, y);

  int columnStart = max(column - size, 0);
  int columnEnd = min(column + size, compiledGame.totalColumns - 1);

  int rowStart = max(row - size, 0);
  int rowEnd = min(row + size, compiledGame.totalRows - 1);

  for (int c = columnStart; c < columnEnd; c++) {
    for (int r = rowStart; r < rowEnd; r++) {
      applyShade(shader, r, c, shade);
    }
  }
}
