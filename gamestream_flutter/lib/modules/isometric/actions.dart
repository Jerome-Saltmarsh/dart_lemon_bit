import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:bleed_common/tileTypeToObjectType.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/mappers/mapTileToSrcRect.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/constants.dart';
import 'package:gamestream_flutter/modules/isometric/properties.dart';
import 'package:gamestream_flutter/modules/isometric/queries.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';

import 'utilities.dart';

final _dynamic = isometric.state.dynamic;
final _tilesSrc = isometric.state.tilesSrc;
final _maxRow = isometric.state.maxRow;
final _maxColumn =  isometric.state.maxRow;
final _rowIndex16 = isometric.state.totalColumnsInt * 16;
final _minRow = isometric.state.minRow;
final _minColumn = isometric.state.minColumn;

class IsometricActions {

  final IsometricState state;
  final IsometricQueries queries;
  final IsometricConstants constants;
  final IsometricProperties properties;
  final _atlasTilesX = atlas.tiles.x;
  final _atlasTilesY = atlas.tiles.y;

  IsometricActions(this.state, this.queries, this.constants, this.properties);

  void refreshGeneratedObjects() {
    final tiles = state.tiles;
    final totalRows = tiles.length;
    final totalColumns = totalRows > 0 ? tiles[0].length : 0;
    for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
       final row = tiles[rowIndex];
       for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++){
         final tile = row[columnIndex];
         final objectType = tileTypeToObjectType[tile];
         if (objectType == null) continue;
         final env = EnvironmentObject(
             x: getTileWorldX(rowIndex, columnIndex),
             y: getTileWorldY(rowIndex, columnIndex) + halfTileSize,
             type: objectType,
             radius: 0
         );
         state.environmentObjects.add(env);
       }
    }
  }

  void applyDynamicShadeToTileSrc() {
    for (var rowIndex = _minRow; rowIndex < _maxRow; rowIndex++) {
      final row = _dynamic[rowIndex];
      for (var columnIndex = _minColumn; columnIndex < _maxColumn; columnIndex++) {
        final i = _rowIndex16 + (columnIndex * 4);
        final top = row[columnIndex] * 48.0;
        _tilesSrc[i + 1] = top; // top
        _tilesSrc[i + 3] = top + tileSize; // bottom
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

  void refreshAmbientLight(){
    print("isometric.actions.refreshAmbientLight()");
    final phase = modules.isometric.map.hourToPhase(state.hours.value);
    final phaseBrightness = modules.isometric.map.phaseToShade(phase);
    final maxAmbientBrightness = state.maxAmbientBrightness.value;
    if (maxAmbientBrightness > phaseBrightness) return;
    state.ambient.value = phaseBrightness;
  }

  void resetBakeMap(){
    print("isometric.actions.resetBakeMap()");
    refreshAmbientLight();
    final bake = state.bake;
    final ambient = state.ambient.value;
    final rows = state.totalRows.value;
    final columns = state.totalColumns.value;
    bake.clear();
    for (var row = 0; row < rows; row++) {
      final _baked = Int8List(columns);
      bake.add(_baked);
      for (var column = 0; column < columns; column++) {
        _baked[column] = ambient;
      }
    }
    applyEnvironmentObjectsToBakeMapping();
  }

  void resetDynamicMap(){
    print("isometric.actions.resetDynamicMap()");
    final dynamic = state.dynamic;
    final rows = state.totalRows.value;
    final columns = state.totalColumns.value;
    final ambient = state.ambient.value;
    dynamic.clear();
    for (var row = 0; row < rows; row++) {
      final dynamicRow = Int8List(columns);
      dynamic.add(dynamicRow);
      for (var column = 0; column < columns; column++) {
        dynamicRow[column] = ambient;
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
    // print("actions.updateTileRender()");
    resetTilesSrcDst();
    resetLighting();
  }

  /// Expensive
  void setTile({
    required int row,
    required int column,
    required int tile,
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
  }

  bool _isBridgeOrWater(int tile){
    return tile != Tile.Water && tile != Tile.Bridge;
  }

  void resetTilesSrcDst() {
    final tiles = state.tiles;
    const tileSize = 48.0;
    final rows = tiles.length;
    final columns = rows > 0 ? tiles[0].length : 0;
    final List<double> tileLeft = [];
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
      final row = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        final tile = row[columnIndex];
        final tileAboveLeft = rowIndex > 0 && _isBridgeOrWater(tiles[rowIndex - 1][columnIndex]);
        final tileAboveRight = columnIndex > 0 && _isBridgeOrWater(row[columnIndex - 1]);
        final tileAbove = rowIndex > 0 &&
            columnIndex > 0 &&
            _isBridgeOrWater(tiles[rowIndex - 1][columnIndex - 1]);

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
      const tileSizeHalf = tileSize / 2;
      tilesDst[index2] = getTileWorldX(row, column) - tileSizeHalf;
      tilesDst[index3] = getTileWorldY(row, column);
      tilesSrc[index0] = _atlasTilesX + tileLeft[i];
      tilesSrc[index1] = _atlasTilesY;
      tilesSrc[index2] = tilesSrc[index0] + tileSize;
      tilesSrc[index3] = tilesSrc[index1] + tileSize;
    }
    state.tilesDst = tilesDst;
    state.tilesSrc = tilesSrc;
  }

  void addRow(){
    final List<int> row = [];
    final rows = state.tiles[0].length;
    for(var i = 0; i < rows; i++){
      row.add(Tile.Grass);
    }
    state.tiles.add(row);
    _refreshMapTiles();
  }

  void removeRow(){
    state.tiles.removeLast();
    _refreshMapTiles();
  }

  void _refreshMapTiles(){
    refreshTileSize();
    resetTilesSrcDst();
    resetLighting();
  }

  void addColumn() {
    for (final row in state.tiles) {
      row.add(Tile.Grass);
    }
    _refreshMapTiles();
  }

  void removeColumn() {
    for (var i = 0; i < state.tiles.length; i++) {
      state.tiles[i].removeLast();
    }
    _refreshMapTiles();
  }

  void detractHour(){
    print("isometric.actions.detractHour()");
    state.hours.value = (state.hours.value - 1) % 24;
  }

  void addHour(){
    state.hours.value = (state.hours.value + 1) % 24;
  }

  void setHour(int hour) {
    print("isometric.actions.setHour($hour)");
    state.minutes.value = hour * secondsPerHour;
  }

  void removeGeneratedEnvironmentObjects(){
    const generated = [
      ObjectType.Palisade,
      ObjectType.Palisade_H,
      ObjectType.Palisade_V,
      ObjectType.Rock_Wall,
      ObjectType.Block_Grass,
    ];
    state.environmentObjects.removeWhere((env) => generated.contains(env));
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
    var rEnd = min(row + size, state.maxRow);
    if (rEnd < state.minRow) return;
    final cStart = max(column - size, state.minColumn);
    if (cStart > state.maxColumn) return;
    var cEnd = min(column + size, state.maxColumn);
    if (cEnd < state.minColumn) return;

    if (rEnd >= state.totalRowsInt){
      rEnd = state.totalRowsInt - 1;
    }
    if (cEnd >= state.totalColumnsInt){
      cEnd = state.totalColumnsInt - 1;
    }

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

  // void applyEmissionFromCharactersBright(List<Character> characters) {
  //   final shading = state.dynamic;
  //   for(final character in characters) {
  //     if (character.dead) continue;
  //     if (!character.allie) continue;
  //     emitLightHigh(shading, character.x, character.y);
  //   }
  // }
  //
  // void applyEmissionFromCharactersMedium(List<Character> characters) {
  //   final dynamicShading = state.dynamic;
  //   for (final character in characters) {
  //     if (character.dead) continue;
  //     if (!character.allie) continue;
  //     emitLightMedium(dynamicShading, character.x, character.y);
  //   }
  // }

  void applyDynamicEmissions() {
    if (properties.dayTime) return;
    resetDynamicShadesToBakeMap();

    final totalPlayers = game.totalPlayers.value;
    final totalNpcs = game.totalNpcs;
    final players = game.players;
    final npcs = game.interactableNpcs;
    final shading = isometric.state.dynamic;

    for (var i = 0; i < totalPlayers; i++){
      final player = players[i];
      if (!player.allie) continue;
      emitLightHigh(shading, player.x, player.y);
    }

    for (var i = 0; i < totalNpcs; i++){
      final npc = npcs[i];
      if (!npc.allie) continue;
      emitLightHigh(shading, npc.x, npc.y);
    }

    applyEmissionFromProjectiles();
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

  void applyEmissionFromProjectiles() {
    final total = game.totalProjectiles;
    final projectiles = game.projectiles;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      if (projectile.type != ProjectileType.Fireball) continue;
      emitLightBrightSmall(state.dynamic, projectile.x, projectile.y);
    }
  }
}