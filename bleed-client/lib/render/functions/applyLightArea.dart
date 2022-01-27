import 'dart:math';

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';

void applyLightArea(List<List<Shade>> shader, int column, int row, int size, Shade shade) {

  int columnStart = max(column - size, 0);
  int columnEnd = min(column + size, modules.isometric.state.totalColumns.value - 1);
  int rowStart = max(row - size, 0);
  int rowEnd = min(row + size, modules.isometric.state.totalRows.value - 1);

  for (int c = columnStart; c < columnEnd; c++) {
    for (int r = rowStart; r < rowEnd; r++) {
      applyShade(shader, r, c, shade);
    }
  }
}
