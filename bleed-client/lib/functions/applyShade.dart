import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/outOfBounds.dart';

void applyShade(List<List<Shading>> shader, int row, int column, Shading value) {
  if (outOfBounds(column, row)) return;
  if (shader[row][column].index <= value.index) return;
  shader[row][column] = value;
}

void applyShadeBright(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Bright);
}

void applyShadeMedium(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Medium);
}

void applyShadeDark(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Dark);
}
