import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/Projectile.dart';
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
    final tileSize = modules.isometric.constants.tileSize;
    int i = 0;
    final dynamicShading = state.dynamicShading;
    for (int row = 0; row < state.totalRows.value; row++) {
      for (int column = 0; column < state.totalColumns.value; column++) {
        final shade = dynamicShading[row][column];
        state.tilesSrc[i + 1] = atlas.tiles.y + shade * tileSize; // top
        state.tilesSrc[i + 3] = state.tilesSrc[i + 1] + tileSize; // bottom
        i += 4;
      }
    }
  }

  /// Expensive method
  void resetLighting(){
    resetBakeMap();
    applyEnvironmentObjectsToBakeMapping();
    resetDynamicMap();
    resetDynamicShadesToBakeMap();
    applyDynamicShadeToTileSrc();
  }

  void resetBakeMap(){
    print("isometric.actions.resetBakeMap()");
    state.bakeMap.clear();
    for (int row = 0; row < state.totalRows.value; row++) {
      final List<int> _baked = [];
      state.bakeMap.add(_baked);
      for (int column = 0; column < state.totalColumns.value; column++) {
        _baked.add(state.ambient.value);
      }
    }
    applyEnvironmentObjectsToBakeMapping();
  }

  void resetDynamicMap(){
    print("isometric.actions.resetDynamicMap()");
    state.dynamicShading.clear();
    for (int row = 0; row < state.totalRows.value; row++) {
      final List<int> _dynamic = [];
      state.dynamicShading.add(_dynamic);
      for (int column = 0; column < state.totalColumns.value; column++) {
        _dynamic.add(state.ambient.value);
      }
    }
  }

  void applyEnvironmentObjectsToBakeMapping(){
    for (EnvironmentObject env in state.environmentObjects){
      if (env.type == ObjectType.Torch){
        emitLightHigh(state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House01){
        emitLightLow(state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House02){
        emitLightLow(state.bakeMap, env.x, env.y);
        continue;
      }
    }
  }

  void resetDynamicShadesToBakeMap() {
    final dynamicShading = state.dynamicShading;
    for (int row = 0; row < dynamicShading.length; row++) {
      for (int column = 0; column < dynamicShading[0].length; column++) {
        dynamicShading[row][column] = state.bakeMap[row][column];
      }
    }
  }

  void updateTileRender(){
    print("actions.updateTileRender()");
    resetBakeMap();
    resetDynamicMap();
    resetTilesSrcDst();
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
    state.totalRows.value = state.tiles.length;
    state.totalColumns.value = state.tiles.isEmpty
        ? 0
        : state.tiles[0].length;
  }

  /// Expensive
  void resetTilesSrcDst() {
    print("isometric.actions.resetTilesSrcDst()");

    final tiles = state.tiles;
    final tileSize = constants.tileSize;
    final tileSizeHalf = tileSize / 2;
    final List<RSTransform> tileTransforms = [];

    for (int x = 0; x < tiles.length; x++) {
      for (int y = 0; y < tiles[0].length; y++) {
        tileTransforms.add(
            RSTransform.fromComponents(
            rotation: 0.0,
            scale: 1.0,
            anchorX: tileSizeHalf,
            anchorY: 0,
            translateX: getTileWorldX(x, y),
            translateY: getTileWorldY(x, y))
        );
      }
    }

    final List<double> tileLeft = [];
    for (int row = 0; row < tiles.length; row++) {
      for (int column = 0; column < tiles[0].length; column++) {
        final tile = tiles[row][column];

        final tileAboveLeft = row > 0 && tiles[row - 1][column] != Tile.Water;
        final tileAboveRight = column > 0 && tiles[row][column - 1] != Tile.Water;
        final tileAbove = row > 0 &&
            column > 0 &&
            tiles[row - 1][column - 1] != Tile.Water;

        if (tile == Tile.Water){
          if (!tileAboveLeft && !tileAboveRight){
            if (tileAbove){
              tileLeft.add(waterCorner4);
            }else{
              tileLeft.add(mapTileToSrcLeft(tile));
            }
          }else if (tileAboveLeft){
            if (tileAboveRight){
              tileLeft.add(waterCorner3);
            }else{
              if (tileAbove){
                  tileLeft.add(waterHor);
              }else{
                tileLeft.add(waterCorner1);
              }
            }
          }else{
            if (tileAbove){
              tileLeft.add(waterVer);
            }else{
              tileLeft.add(waterCorner2);
            }
          }
        } else {
          tileLeft.add(mapTileToSrcLeft(tile));
        }
      }
    }

    final total = tileLeft.length * 4;
    final tilesDst = Float32List(total);
    final tilesSrc = Float32List(total);

    for (int i = 0; i < tileLeft.length; ++i) {
      final int index0 = i * 4;
      final int index1 = index0 + 1;
      final int index2 = index0 + 2;
      final int index3 = index0 + 3;
      final RSTransform rstTransform = tileTransforms[i];
      tilesDst[index0] = rstTransform.scos;
      tilesDst[index1] = rstTransform.ssin;
      tilesDst[index2] = rstTransform.tx;
      tilesDst[index3] = rstTransform.ty;
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
    engine.actions.cameraCenter(properties.mapCenter.x, properties.mapCenter.y);
  }

  void applyShadeDynamic(int row, int column, int value) {
    applyShade(state.dynamicShading, row, column, value);
  }

  void applyShadeDynamicPosition(double x, double y, int value) {
    final row = getRow(x,  y);
    final column = getColumn(x, y);
    applyShade(state.dynamicShading, row, column, value);
  }

  void applyShade(
      List<List<int>> shader, int row, int column, int value) {
    if (queries.outOfBounds(row, column)) return;
    if (shader[row][column] <= value) return;
    shader[row][column] = value;
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



  void applyShadeBright(List<List<int>> shader, int row, int column) {
    applyShade(shader, row, column, Shade.Bright);
  }

  void applyShadeMedium(List<List<int>> shader, int row, int column) {
    applyShade(shader, row, column, Shade.Medium);
  }

  void applyShadeDark(List<List<int>> shader, int row, int column) {
    applyShade(shader, row, column, Shade.Dark);
  }

  void applyShadeRing(List<List<int>> shader, int row, int column, int size, int shade) {

    if (shade >= state.ambient.value) return;

    int rStart = row - size;
    int rEnd = row + size;
    int cStart = column - size;
    int cEnd = column + size;

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

    for (int r = rStart; r <= rEnd; r++) {
      applyShadeUnchecked(shader, r, cStart, shade);
      applyShadeUnchecked(shader, r, cEnd, shade);
    }
    for (int c = cStart + 1; c < cEnd; c++) {
      applyShadeUnchecked(shader, rStart, c, shade);
      applyShadeUnchecked(shader, rEnd, c, shade);
    }
  }

  void emitLightMedium(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);

    if (row < 0) return;
    if (column < 0) return;
    if (row >= shader.length) return;
    if (column >= shader[0].length) return;

    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHigh(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);

    if (row < 0) return;
    if (column < 0) return;
    if (row >= shader.length) return;
    if (column >= shader[0].length) return;

    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);

    if (row < 0) return;
    if (column < 0) return;
    if (row >= shader.length) return;
    if (column >= shader[0].length) return;

    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void applyCharacterLightEmission(List<Character> characters) {
    for(Character character in characters) {
      if (character.team != modules.game.state.player.team) continue;
      emitLightHigh(state.dynamicShading, character.x, character.y);
    }
  }

  void applyNpcLightEmission(List<Character> characters) {
    final dynamicShading = state.dynamicShading;
    for (Character character in characters) {
      emitLightMedium(dynamicShading, character.x, character.y);
    }
  }

  void applyLightArea(List<List<int>> shader, int column, int row, int size, int shade) {

    int columnStart = max(column - size, 0);
    int columnEnd = min(column + size, state.totalColumns.value - 1);
    int rowStart = max(row - size, 0);
    int rowEnd = min(row + size, state.totalRows.value - 1);

    for (int c = columnStart; c < columnEnd; c++) {
      for (int r = rowStart; r < rowEnd; r++) {
        applyShade(shader, r, c, shade);
      }
    }
  }

  void applyShadeUnchecked(
      List<List<int>> shader, int row, int column, int value) {
    if (shader[row][column] <= value) return;
    shader[row][column] = value;
  }

  void applyEmissionsToDynamicShadeMap() {
    if (modules.isometric.properties.dayTime) return;
    modules.isometric.actions.resetDynamicShadesToBakeMap();
    applyCharacterLightEmission(game.humans);
    applyCharacterLightEmission(game.zombies);
    applyProjectileLighting();
    applyNpcLightEmission(game.interactableNpcs);

    for (final item in state.items) {
      applyShadeDynamicPosition(item.x, item.y, Shade.Bright);
    }

    final dynamicShading = state.dynamicShading;

    for (Effect effect in game.effects) {
      if (!effect.enabled) continue;
      double p = effect.duration / effect.maxDuration;
      if (p < 0.33) {
        emitLightHigh(dynamicShading, effect.x, effect.y);
        break;
      }
      if (p < 0.66) {
        emitLightMedium(dynamicShading, effect.x, effect.y);
        break;
      }
      emitLightLow(dynamicShading, effect.x, effect.y);
    }
  }

  void applyProjectileLighting() {
    for (int i = 0; i < game.totalProjectiles; i++) {
      Projectile projectile = game.projectiles[i];
      if (projectile.type == ProjectileType.Fireball) {
        emitLightBrightSmall(state.dynamicShading, projectile.x, projectile.y);
      }
    }
  }
}