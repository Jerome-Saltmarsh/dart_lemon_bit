import 'dart:math';

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/render/drawCanvas.dart';
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

void applyLightBright(List<List<Shading>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);

  applyLightArea(shader, x, y, 7, Shading.Dark);
  applyLightArea(shader, x, y, 4, Shading.Medium);
  applyLightArea(shader, x, y, 2, Shading.Bright);

  applyShadeBright(shader, row, column);

  if (row > 1) {
    applyShadeMedium(shader, row - 2, column);
    if (column > 0) {
      applyShadeDark(shader, row - 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row - 2, column - 2);
    }
    if (column < compiledGame.totalColumns - 1) {
      applyShadeDark(shader, row - 2, column + 1);
    }
    if (column < compiledGame.totalColumns - 2) {
      applyShadeDark(shader, row - 2, column + 2);
    }
  }
  if (row < compiledGame.totalRows - 2) {
    applyShadeMedium(shader, row + 2, column);

    if (column > 0) {
      applyShadeDark(shader, row + 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row + 2, column - 2);
    }
    if (column < compiledGame.totalColumns - 1) {
      applyShadeDark(shader, row + 2, column + 1);
    }
    if (column < compiledGame.totalColumns - 2) {
      applyShadeDark(shader, row + 2, column + 2);
    }
  }

  if (column > 0) {
    applyShadeMedium(shader, row, column - 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column - 2);
    }
    if (row < compiledGame.totalRows - 1) {
      applyShadeDark(shader, row + 1, column - 2);
    }
  }
  if (column < compiledGame.totalColumns - 1) {
    applyShadeMedium(shader, row, column + 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column + 2);
    }
    if (row < compiledGame.totalRows - 1) {
      applyShadeDark(shader, row + 1, column + 2);
    }
  }

  if (row > 0) {
    applyShadeBright(shader, row - 1, column);
    if (column > 0) {
      applyShadeMedium(shader, row - 1, column - 1);
    }
    if (column + 1 < compiledGame.totalColumns) {
      applyShadeMedium(shader, row - 1, column + 1);
    }
  }
  if (column > 0) {
    applyShadeBright(shader, row, column - 1);
  }
  if (column + 1 < compiledGame.totalColumns) {
    applyShadeBright(shader, row, column + 1);
    if (row + 1 < compiledGame.totalRows) {
      applyShadeMedium(shader, row + 1, column + 1);
    }
  }
  if (row + 1 < compiledGame.totalRows) {
    applyShadeBright(shader, row + 1, column);

    if (column > 0) {
      applyShadeMedium(shader, row + 1, column - 1);
    }
  }
}
