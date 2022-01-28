import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/outOfBounds.dart';
import 'package:bleed_client/modules/modules.dart';

final _state = modules.isometric.state;

void applyShade(
    List<List<Shade>> shader, int row, int column, Shade value) {
  if (outOfBounds(row, column)) return;
  if (shader[row][column].index <= value.index) return;
  shader[row][column] = value;
}

void applyShadeUnchecked(
    List<List<Shade>> shader, int row, int column, Shade value) {
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

  if (shade.index >= modules.isometric.state.ambient.value.index) return;

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
