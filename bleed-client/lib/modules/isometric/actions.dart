import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/constants.dart';
import 'package:bleed_client/modules/isometric/properties.dart';
import 'package:bleed_client/modules/isometric/queries.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

import 'utilities.dart';

class IsometricActions {

  final IsometricState state;
  final IsometricQueries queries;
  final IsometricConstants constants;
  final IsometricProperties properties;

  IsometricActions(this.state, this.queries, this.constants, this.properties);

  void applyDynamicShadeToTileSrc() {
    final tileSize = constants.tileSize;
    final atlasY = atlas.tiles.y;
    final dynamic = state.dynamic;
    final tilesSrc = state.tilesSrc;
    final maxRow = state.maxRow;
    final maxColumn =  state.maxRow;
    final rowIndex16 = state.totalColumnsInt * 16;
    final minRow = state.minRow;
    final minColumn = state.minColumn;
    for (var rowIndex = minRow; rowIndex < maxRow; rowIndex++) {
      final row = dynamic[rowIndex];
      for (var columnIndex = minColumn; columnIndex < maxColumn; columnIndex++) {
        final i = rowIndex16 + (columnIndex * 4);
        final top = atlasY + row[columnIndex] * tileSize;
        tilesSrc[i + 1] = top; // top
        tilesSrc[i + 3] = top + tileSize; // bottom
      }
    }
  }

  /// Expensive method
  void resetLighting(){
    print("isometric.actions.resetLighting()");
    refreshTileSize();
    resetBakeMap();
    resetDynamicMap();
    resetDynamicShadesToBakeMap();
    applyDynamicShadeToTileSrc();
  }

  void resetBakeMap(){
    print("isometric.actions.resetBakeMap()");
    final bake = state.bake;
    final ambient = state.ambient.value;
    final rows = state.totalRows.value;
    final columns = state.totalColumns.value;
    bake.clear();
    for (var row = 0; row < rows; row++) {
      final List<int> _baked = [];
      bake.add(_baked);
      for (var column = 0; column < columns; column++) {
        _baked.add(ambient);
      }
    }
    applyEnvironmentObjectsToBakeMapping();
  }

  void resetDynamicMap(){
    print("isometric.actions.resetDynamicMap()");
    final dynamic = state.dynamic;
    dynamic.clear();
    for (var row = 0; row < state.totalRows.value; row++) {
      final List<int> dynamicRow = [];
      dynamic.add(dynamicRow);
      for (var column = 0; column < state.totalColumns.value; column++) {
        dynamicRow.add(state.ambient.value);
      }
    }
  }

  void applyEnvironmentObjectsToBakeMapping(){
    print("isometric.actions.applyEnvironmentObjectsToBakeMapping()");
    for (final env in state.environmentObjects){
      final type = env.type;
      if (type == ObjectType.Torch){
        emitLightBakeHigh(env.x, env.y);
        continue;
      }
      if (type == ObjectType.House01){
        emitLightMedium(state.bake, env.x, env.y);
        continue;
      }
      if (type == ObjectType.House02){
        emitLightMedium(state.bake, env.x, env.y);
        continue;
      }
    }
  }

  void resetDynamicShadesToBakeMap() {
    final minRow = state.minRow;
    final maxRow = state.maxRow;
    final minColumn = state.minColumn;
    final maxColumn = state.maxColumn;
    final dynamic = state.dynamic;
    final bake = state.bake;
    for (var row = minRow; row < maxRow; row++) {
      final dynamicRow = dynamic[row];
      final bakeRow = bake[row];
      for (var column = minColumn; column < maxColumn; column++) {
        dynamicRow[column] = bakeRow[column];
      }
    }
  }

  void updateTileRender(){
    print("actions.updateTileRender()");
    resetTilesSrcDst();
    resetLighting();
  }

  /// Expensive
  void setTile({
    required int row,
    required int column,
    required Tile tile,
  }) {
    if (row < 0) return;
    if (column < 0) return;
    if (row >= state.totalRows.value) return;
    if (column >= state.totalColumns.value) return;
    if (state.tiles[row][column] == tile) return;
    state.tiles[row][column] = tile;
    resetTilesSrcDst();
  }

  void refreshTileSize(){
    final screen = engine.screen;
    final tiles = state.tiles;
    final rows = tiles.length;
    final columns = tiles.length > 0 ? tiles[0].length : 0;
    state.totalRows.value = rows;
    state.totalColumns.value = columns;
    state.minRow = max(0, getRow(screen.left, screen.top));
    state.maxRow = min(rows, getRow(screen.right, screen.bottom));
    state.minColumn = max(0, getColumn(screen.right, screen.top));
    state.maxColumn = min(columns, getColumn(screen.left, screen.bottom));
    if (state.minRow > state.maxRow){
       state.minRow = state.maxRow;
    }
    if (state.minColumn > state.maxColumn){
      state.minColumn = state.maxColumn;
    }
    // assert(state.minRow <= state.maxRow);
    // assert(state.minColumn <= state.maxColumn);
  }

  void resetTilesSrcDst() {
    print("isometric.actions.resetTilesSrcDst()");
    final tiles = state.tiles;
    final tileSize = constants.tileSize;
    final tileSizeHalf = tileSize / 2;
    final rows = tiles.length;
    final columns = tiles[0].length;
    final List<double> tileLeft = [];
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
      final row = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        final tile = row[columnIndex];
        final tileAboveLeft = rowIndex > 0 && tiles[rowIndex - 1][columnIndex] != Tile.Water;
        final tileAboveRight = columnIndex > 0 && row[columnIndex - 1] != Tile.Water;
        final tileAbove = rowIndex > 0 &&
            columnIndex > 0 &&
            tiles[rowIndex - 1][columnIndex - 1] != Tile.Water;

        if (tile == Tile.Water) {
          if (!tileAboveLeft && !tileAboveRight) {
            if (tileAbove) {
              tileLeft.add(waterCorner4);
            } else {
              tileLeft.add(mapTileToSrcLeft(tile));
            }
          } else if (tileAboveLeft) {
            if (tileAboveRight) {
              tileLeft.add(waterCorner3);
            } else {
              if (tileAbove) {
                  tileLeft.add(waterHor);
              } else {
                tileLeft.add(waterCorner1);
              }
            }
          } else {
            if (tileAbove) {
              tileLeft.add(waterVer);
            } else {
              tileLeft.add(waterCorner2);
            }
          }
        } else {
          tileLeft.add(mapTileToSrcLeft(tile));
        }
      }
    }

    final tileLeftLength = tileLeft.length;
    final total = tileLeftLength * 4;
    late Float32List tilesDst;
    late Float32List tilesSrc;
    if (state.tilesDst.length != total) {
      tilesDst = Float32List(total);
      tilesSrc = Float32List(total);
    } else {
      tilesDst = state.tilesDst;
      tilesSrc = state.tilesSrc;
    }

    for (var i = 0; i < tileLeftLength; ++i) {
      final index0 = i * 4;
      final index1 = index0 + 1;
      final index2 = index0 + 2;
      final index3 = index0 + 3;
      final row = i ~/ columns;
      final column = i % columns;
      tilesDst[index0] = 1;
      tilesDst[index1] = 0;
      tilesDst[index2] = getTileWorldX(row, column) - tileSizeHalf;
      tilesDst[index3] = getTileWorldY(row, column);
      tilesSrc[index0] = atlas.tiles.x + tileLeft[i];
      tilesSrc[index1] = atlas.tiles.y;
      tilesSrc[index2] = tilesSrc[index0] + tileSize;
      tilesSrc[index3] = tilesSrc[index1] + tileSize;
    }
    state.tilesDst = tilesDst;
    state.tilesSrc = tilesSrc;
  }

  void addRow(){
    final List<Tile> row = [];
    for(int i = 0; i < state.tiles[0].length; i++){
      row.add(Tile.Grass);
    }
    state.tiles.add(row);
    refreshTileSize();
    resetTilesSrcDst();
  }

  void removeRow(){
    state.tiles.removeLast();
    refreshTileSize();
    resetTilesSrcDst();
  }

  void addColumn() {
    for (final row in state.tiles) {
      row.add(Tile.Grass);
    }
    refreshTileSize();
    resetTilesSrcDst();
  }

  void removeColumn() {
    for (int i = 0; i < state.tiles.length; i++) {
      state.tiles[i].removeLast();
    }
    refreshTileSize();
    resetTilesSrcDst();
  }

  void detractHour(){
    print("isometric.actions.detractHour()");
    final amount = state.time.value - secondsPerHour;
    if (amount > 0) {
      state.time.value = amount;
    } else {
      state.time.value = secondsPerDay + amount;
    }
  }

  void addHour(){
    state.time.value += secondsPerHour;
  }

  void setHour(int hour) {
    print("isometric.actions.setHour($hour)");
    state.time.value = hour * secondsPerHour;
  }

  void removeGeneratedEnvironmentObjects(){
    state.environmentObjects.removeWhere((env) => isGeneratedAtBuild(env.type));
  }

  void cameraCenterMap(){
    engine.cameraCenter(properties.mapCenter.x, properties.mapCenter.y);
  }

  void applyShadeDynamicPositionUnchecked(double x, double y, int value) {
    shadeDynamic(getRow(x,  y), getColumn(x, y), value);
  }

  void shadeDynamic(int row, int column, int value) {
    applyShade(state.dynamic, row, column, value);
  }

  void shadeBake(int row, int column, int value) {
    applyShade(state.bake, row, column, value);
  }

  void applyShade(List<List<int>> shader, int row, int column, int value) {
    applyShadeAtRow(shader[row], column, value);
  }

  void applyShadeAtRow(List<int> shadeRow, int column, int value) {
    if (shadeRow[column] <= value) return;
    shadeRow[column] = value;
  }


  void emitLightLow(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    if (column < 0) return;
    if (column >= shader[0].length) return;
    final row = getRow(x, y);
    if (row < 0) return;
    if (row >= shader.length) return;

    applyShade(shader, row, column, Shade.Medium);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void applyShadeRing(List<List<int>> shader, int row, int column, int size, int shade) {
    if (shade >= state.ambient.value) return;
    final rStart = max(row - size, state.minRow);
    if (rStart > state.maxRow) return;
    final rEnd = min(row + size, state.maxRow);
    if (rEnd < state.minRow) return;
    final cStart = max(column - size, state.minColumn);
    if (cStart > state.maxColumn) return;
    final cEnd = min(column + size, state.maxColumn);
    if (cEnd < state.minColumn) return;

    final rowStart = shader[rStart];
    final rowEnd = shader[rEnd];

    for (var r = rStart + 1; r < rEnd; r++) {
      final shadeRow = shader[r];
      applyShadeAtRow(shadeRow, cStart, shade);
      applyShadeAtRow(shadeRow, cEnd, shade);
    }
    for (var c = cStart; c <= cEnd; c++) {
      applyShadeAtRow(rowStart, c, shade);
      applyShadeAtRow(rowEnd, c, shade);
    }
  }

  void bakeShadeRing(int row, int column, int size, int shade) {

    if (shade >= state.ambient.value) return;

    var rStart = row - size;
    var rEnd = row + size;
    var cStart = column - size;
    var cEnd = column + size;

    if (rStart < 0) {
      rStart = 0;
    } else if (rStart >= state.totalRowsInt) {
      return;
    }

    if (rEnd >= state.totalRowsInt){
      rEnd = state.totalRowsInt - 1;
    } else if(rEnd < 0) {
      return;
    }

    if (cStart < 0) {
      cStart = 0;
    } else if (cStart >= state.totalColumnsInt) {
      return;
    }

    if (cEnd >= state.totalColumnsInt){
      cEnd = state.totalColumnsInt - 1;
    } else if(cEnd < 0) {
      return;
    }

    for (var r = rStart; r <= rEnd; r++) {
      shadeBake(r, cStart, shade);
      shadeBake(r, cEnd, shade);
    }
    for (var c = cStart + 1; c < cEnd; c++) {
      shadeBake(rStart, c, shade);
      shadeBake(rEnd, c, shade);
    }
  }


  void emitLightMedium(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (queries.outOfBounds(row, column)) return;

    applyShade(shader, row, column, Shade.Medium);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHigh(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (queries.outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightBakeHigh(double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (queries.outOfBounds(row, column)) return;
    shadeBake(row, column, Shade.Bright);
    bakeShadeRing(row, column, 1, Shade.Bright);
    bakeShadeRing(row, column, 2, Shade.Medium);
    bakeShadeRing(row, column, 3, Shade.Dark);
    bakeShadeRing(row, column, 4, Shade.Very_Dark);
  }

  void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (queries.outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void applyEmissionFromCharactersBright(List<Character> characters) {
    final shading = state.dynamic;
    final playerTeam = modules.game.state.player.team;
    for(final character in characters) {
      if (character.team != playerTeam) continue;
      emitLightHigh(shading, character.x, character.y);
    }
  }

  void applyEmissionFromCharactersMedium(List<Character> characters) {
    final dynamicShading = state.dynamic;
    for (final character in characters) {
      emitLightMedium(dynamicShading, character.x, character.y);
    }
  }

  void applyDynamicEmissions() {
    if (properties.dayTime) return;
    resetDynamicShadesToBakeMap();
    applyEmissionFromCharactersBright(game.humans);
    // applyEmissionFromCharactersMedium(game.zombies);
    applyEmissionFromCharactersMedium(game.interactableNpcs);
    applyEmissionFromProjectiles();
    // applyEmissionFromItems();
    applyEmissionFromEffects();
  }

  void applyEmissionFromEffects() {
    final dynamicShading = state.dynamic;
    for (final effect in game.effects) {
      if (!effect.enabled) continue;
      final percentage = effect.percentage;
      if (percentage < 0.33) {
        emitLightHigh(dynamicShading, effect.x, effect.y);
        break;
      }
      if (percentage < 0.66) {
        emitLightMedium(dynamicShading, effect.x, effect.y);
        break;
      }
      emitLightLow(dynamicShading, effect.x, effect.y);
    }
  }

  void applyEmissionFromItems() {
    for (final item in state.items) {
      applyShadeDynamicPositionUnchecked(item.x, item.y, Shade.Bright);
    }
  }

  void applyEmissionFromProjectiles() {
    final total = game.totalProjectiles;
    for (var i = 0; i < total; i++) {
      final projectile = game.projectiles[i];
      if (projectile.type != ProjectileType.Fireball) continue;
      emitLightBrightSmall(state.dynamic, projectile.x, projectile.y);
    }
  }
}