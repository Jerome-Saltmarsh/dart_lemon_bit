import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void applyLightMedium(List<List<Shading>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShadeMedium(shader, row, column);

  if (row > 1) {
    applyShadeDark(shader, row - 2, column);
    if (column > 0) {
      applyShadeDark(shader, row - 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row - 2, column - 2);
    }
    if (column < game.totalColumns - 1) {
      applyShadeDark(shader, row - 2, column + 1);
    }
    if (column < game.totalColumns - 2) {
      applyShadeDark(shader, row - 2, column + 2);
    }
  }
  if (row < game.totalRows - 2) {
    applyShadeDark(shader, row + 2, column);

    if (column > 0) {
      applyShadeDark(shader, row + 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row + 2, column - 2);
    }
    if (column < game.totalColumns - 1) {
      applyShadeDark(shader, row + 2, column + 1);
    }
    if (column < game.totalColumns - 2) {
      applyShadeDark(shader, row + 2, column + 2);
    }
  }

  if (column > 0) {
    applyShadeDark(shader, row, column - 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column - 2);
    }
    if (row < game.totalRows - 1) {
      applyShadeDark(shader, row + 1, column - 2);
    }
  }
  if (column < game.totalColumns - 1) {
    applyShadeDark(shader, row, column + 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column + 2);
    }
    if (row < game.totalRows - 1) {
      applyShadeDark(shader, row + 1, column + 2);
    }
  }

  if (row > 0) {
    applyShadeMedium(shader, row - 1, column);
    if (column > 0) {
      applyShadeMedium(shader, row - 1, column - 1);
    }
    if (column + 1 < game.totalColumns) {
      applyShadeMedium(shader, row - 1, column + 1);
    }
  }
  if (column > 0) {
    applyShadeMedium(shader, row, column - 1);
  }
  if (column + 1 < game.totalColumns) {
    applyShadeMedium(shader, row, column + 1);
    if (row + 1 < game.totalRows) {
      applyShadeMedium(shader, row + 1, column + 1);
    }
  }
  if (row + 1 < game.totalRows) {
    applyShadeMedium(shader, row + 1, column);

    if (column > 0) {
      applyShadeMedium(shader, row + 1, column - 1);
    }
  }
}
