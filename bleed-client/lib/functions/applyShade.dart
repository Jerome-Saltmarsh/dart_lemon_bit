import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/outOfBounds.dart';
import 'package:bleed_client/watches/ambientLight.dart';

void applyShade(
    List<List<Shade>> shader, int row, int column, Shade value) {
  if (outOfBounds(row, column)) return;
  if (shader[row][column].index <= value.index) return;
  shader[row][column] = value;
}

void applyShadeBright(List<List<Shade>> shader, int row, int column) {
  applyShade(shader, row, column, Shade.Bright);
}

void applyShadeMedium(List<List<Shade>> shader, int row, int column) {
  applyShade(shader, row, column, Shade.Medium);
}

void applyShadeDark(List<List<Shade>> shader, int row, int column) {
  applyShade(shader, row, column, Shade.Dark);
}

void applyShadeRing(List<List<Shade>> shader, int row, int column, int size, Shade shade) {

  if (shade.index >= ambient.index) return;

  int rStart = row - size;
  int rEnd = row + size;
  int cStart = column - size;
  int cEnd = column + size;

  for (int r = rStart; r <= rEnd; r++) {
    applyShade(shader, r, cStart, shade);
    applyShade(shader, r, cEnd, shade);
  }
  for (int c = cStart; c <= cEnd; c++) {
    applyShade(shader, rStart, c, shade);
    applyShade(shader, rEnd, c, shade);
  }
}
