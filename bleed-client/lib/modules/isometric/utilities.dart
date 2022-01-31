import 'dart:math';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

final tileSize = isometric.constants.tileSize;
final halfTileSize = isometric.constants.halfTileSize;

final _state = modules.isometric.state;

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

double projectedToWorldX(double x, double y) {
  return y - x;
}

double projectedToWorldY(double x, double y) {
  return x + y;
}

double getTileWorldX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTileWorldY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize);
}

Vector2 getTilePosition({required int row, required int column}){
  return Vector2(
    getTileWorldX(row, column),
    getTileWorldY(row, column),
  );
}

double get mouseUnprojectPositionX =>    projectedToWorldX(mouseWorldX, mouseWorldY);

double get mouseUnprojectPositionY =>
    projectedToWorldY(mouseWorldX, mouseWorldY);

int get mouseColumn {
  return mouseUnprojectPositionX ~/ isometric.constants.tileSize;
}

int get mouseRow {
  return mouseUnprojectPositionY ~/ isometric.constants.tileSize;
}

double shiftHeight(double z) {
  return -z * 20;
}

double shiftScale(double z) {
  return 1 + (z * 0.15);
}

Tile getTile(int row, int column){
  if (outOfBounds(row, column)) return Tile.Boundary;
  return _state.tiles[row][column];
}

bool outOfBounds(int row, int column){
  if (row < 0) return true;
  if (column < 0) return true;
  if (row >= _state.totalRowsInt) return true;
  if (column >= _state.totalColumnsInt) return true;
  return false;
}

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
  for (int c = cStart + 1; c < cEnd; c++) {
    applyShadeUnchecked(shader, rStart, c, shade);
    applyShadeUnchecked(shader, rEnd, c, shade);
  }
}


void emitLightLow(List<List<int>> shader, double x, double y) {
  final column = getColumn(x, y);
  if (column < 0) return;
  if (column >= shader[0].length) return;
  final row = getRow(x, y);
  if (row < 0) return;
  if (row >= shader.length) return;


  applyShade(shader, row, column, Shade_Medium);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Dark);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
}

void emitLightMedium(List<List<int>> shader, double x, double y) {
  final column = getColumn(x, y);
  final row = getRow(x, y);

  if (row < 0) return;
  if (column < 0) return;
  if (row >= shader.length) return;
  if (column >= shader[0].length) return;

  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Medium);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
  applyShadeRing(shader, row, column, 4, Shade_VeryDark);
}

void emitLightHigh(List<List<int>> shader, double x, double y) {
  final column = getColumn(x, y);
  final row = getRow(x, y);

  if (row < 0) return;
  if (column < 0) return;
  if (row >= shader.length) return;
  if (column >= shader[0].length) return;

  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Bright);
  applyShadeRing(shader, row, column, 2, Shade_Medium);
  applyShadeRing(shader, row, column, 3, Shade_Dark);
  applyShadeRing(shader, row, column, 4, Shade_VeryDark);
}

void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
  final column = getColumn(x, y);
  final row = getRow(x, y);

  if (row < 0) return;
  if (column < 0) return;
  if (row >= shader.length) return;
  if (column >= shader[0].length) return;

  applyShade(shader, row, column, Shade_Bright);
  applyShadeRing(shader, row, column, 1, Shade_Medium);
  applyShadeRing(shader, row, column, 2, Shade_Dark);
  applyShadeRing(shader, row, column, 3, Shade_VeryDark);
}

void applyCharacterLightEmission(List<Character> characters) {
  for(Character character in characters){
    if (character.team != modules.game.state.player.team) continue;
    emitLightHigh(isometric.state.dynamicShading, character.x, character.y);
  }
}

void applyNpcLightEmission(List<Character> characters) {
  final dynamicShading = isometric.state.dynamicShading;
  for (Character character in characters) {
    emitLightMedium(dynamicShading, character.x, character.y);
  }
}

void applyLightArea(List<List<int>> shader, int column, int row, int size, int shade) {

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
