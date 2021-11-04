import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyShade.dart';
import 'package:bleed_client/getters/getTileAt.dart';

void applyLightMedium(List<List<Shading>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShadeMedium(shader, row, column);
  applyShadeDark(shader, row - 2, column);
  applyShadeDark(shader, row - 2, column - 1);
  applyShadeDark(shader, row - 2, column - 2);
  applyShadeDark(shader, row - 2, column + 1);
  applyShadeDark(shader, row - 2, column + 2);
  applyShadeDark(shader, row + 2, column);
  applyShadeDark(shader, row + 2, column - 1);
  applyShadeDark(shader, row + 2, column - 2);
  applyShadeDark(shader, row + 2, column + 1);
  applyShadeDark(shader, row + 2, column + 2);
  applyShadeDark(shader, row, column - 2);
  applyShadeDark(shader, row - 1, column - 2);
  applyShadeDark(shader, row + 1, column - 2);
  applyShadeDark(shader, row, column + 2);
  applyShadeDark(shader, row - 1, column + 2);
  applyShadeDark(shader, row + 1, column + 2);
  applyShadeMedium(shader, row - 1, column);
  applyShadeMedium(shader, row - 1, column - 1);
  applyShadeMedium(shader, row - 1, column + 1);
  applyShadeMedium(shader, row, column - 1);
  applyShadeMedium(shader, row, column + 1);
  applyShadeMedium(shader, row + 1, column + 1);
  applyShadeMedium(shader, row + 1, column);
  applyShadeMedium(shader, row + 1, column - 1);
}
