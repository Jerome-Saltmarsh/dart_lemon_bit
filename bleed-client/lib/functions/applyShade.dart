import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';

final _state = modules.isometric.state;

void applyShade(
    List<List<int>> shader, int row, int column, int value) {
  if (outOfBounds(row, column)) return;
  if (shader[row][column] <= value) return;
  shader[row][column] = value;
}

void applyShadeUnchecked(
    List<List<int>> shader, int row, int column, int value) {
  if (shader[row][column] <= value) return;
  shader[row][column] = value;
}

void applyShadeBright(List<List<int>> shader, int row, int column) {
  applyShade(shader, row, column, Shade_Bright);
}

void applyShadeMedium(List<List<int>> shader, int row, int column) {
  applyShade(shader, row, column, Shade_Medium);
}

void applyShadeDark(List<List<int>> shader, int row, int column) {
  applyShade(shader, row, column, Shade_Dark);
}

void applyShadeRing(List<List<int>> shader, int row, int column, int size, int shade) {

  if (shade >= _state.ambient.value) return;

  int rStart = row - size;
  int rEnd = row + size;
  int cStart = column - size;
  int cEnd = column + size;

  if (rStart < 0) {
    rStart = 0;
  } else if (rStart >= _state.totalRowsInt) {
    return;
  }

  if (rEnd >= _state.totalRowsInt){
    rEnd = _state.totalRowsInt - 1;
  } else if(rEnd < 0) {
    return;
  }

  if (cStart < 0) {
    cStart = 0;
  } else if (cStart >= _state.totalColumnsInt) {
    return;
  }

  if (cEnd >= _state.totalColumnsInt){
    cEnd = _state.totalColumnsInt - 1;
  } else if(cEnd < 0) {
    return;
  }

  for (int r = rStart; r <= rEnd; r++) {
    applyShadeUnchecked(shader, r, cStart, shade);
    applyShadeUnchecked(shader, r, cEnd, shade);
  }
  for (int c = cStart; c <= cEnd; c++) {
    applyShadeUnchecked(shader, rStart, c, shade);
    applyShadeUnchecked(shader, rEnd, c, shade);
  }
}
