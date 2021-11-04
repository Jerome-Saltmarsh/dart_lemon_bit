import 'dart:math';

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/state/game.dart';

void applyLightArea(List<List<Shading>> shader, int column, int row, int size, Shading shade) {

  int columnStart = max(column - size, 0);
  int columnEnd = min(column + size, game.totalColumns - 1);
  int rowStart = max(row - size, 0);
  int rowEnd = min(row + size, game.totalRows - 1);

  for (int c = columnStart; c < columnEnd; c++) {
    for (int r = rowStart; r < rowEnd; r++) {
      applyShade(shader, r, c, shade);
    }
  }
}
