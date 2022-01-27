import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/modules/isometric/scope.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/functions/emitLight.dart';

class IsometricActions with IsometricScope {

  void applyDynamicShadeToTileSrc() {
    final tileSize = modules.isometric.constants.tileSize;
    int i = 0;
    final state = modules.isometric.state;
    final dynamicShading = state.dynamicShading;
    for (int row = 0; row < modules.isometric.state.totalRows.value; row++) {
      for (int column = 0; column < modules.isometric.state.totalColumns.value; column++) {
        Shade shade = dynamicShading[row][column];
        state.tilesSrc[i + 1] = atlas.tiles.y + shade.index * tileSize; // top
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
    for (int row = 0; row < modules.isometric.state.totalRows.value; row++) {
      final List<Shade> _baked = [];
      state.bakeMap.add(_baked);
      for (int column = 0; column < modules.isometric.state.totalColumns.value; column++) {
        _baked.add(state.ambient.value);
      }
    }
    applyEnvironmentObjectsToBakeMapping();
  }


  void resetDynamicMap(){
    print("isometric.actions.resetDynamicMap()");
    modules.isometric.state.dynamicShading.clear();
    for (int row = 0; row < modules.isometric.state.totalRows.value; row++) {
      final List<Shade> _dynamic = [];
      modules.isometric.state.dynamicShading.add(_dynamic);
      for (int column = 0; column < modules.isometric.state.totalColumns.value; column++) {
        _dynamic.add(modules.isometric.state.ambient.value);
      }
    }
  }

  void applyEnvironmentObjectsToBakeMapping(){
    for (EnvironmentObject env in modules.isometric.state.environmentObjects){
      if (env.type == ObjectType.Torch){
        emitLightHigh(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House01){
        emitLightLow(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
      if (env.type == ObjectType.House02){
        emitLightLow(modules.isometric.state.bakeMap, env.x, env.y);
        continue;
      }
    }
  }

  void resetDynamicShadesToBakeMap() {
    final dynamicShading = modules.isometric.state.dynamicShading;
    for (int row = 0; row < dynamicShading.length; row++) {
      for (int column = 0; column < dynamicShading[0].length; column++) {
        dynamicShading[row][column] = modules.isometric.state.bakeMap[row][column];
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
    final tileSize = modules.isometric.constants.tileSize;
    final tileSizeHalf = tileSize / 2;
    final List<RSTransform> tileTransforms = [];

    for (int x = 0; x < tiles.length; x++) {
      for (int y = 0; y < tiles[0].length; y++) {
        tileTransforms.add(
            RSTransform.fromComponents(
            rotation: 0.0,
            scale: 1.0,
            anchorX: tileSizeHalf,
            anchorY: tileSize,
            translateX: getTileWorldX(x, y),
            translateY: getTileWorldY(x, y))
        );
      }
    }

    final List<double> tileLeft = [];
    tileLeft.clear();
    for (int row = 0; row < tiles.length; row++) {
      for (int column = 0; column < tiles[0].length; column++) {
        tileLeft.add(mapTileToSrc(tiles[row][column]));
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
      tilesDst[index3] = rstTransform.ty + tileSizeHalf;
      tilesSrc[index0] = atlas.tiles.x + tileLeft[i];
      tilesSrc[index1] = atlas.tiles.y;
      tilesSrc[index2] = tilesSrc[index0] + tileSize;
      tilesSrc[index3] = tilesSrc[index1] + tileSize;
    }
    state.tilesDst = tilesDst;
    state.tilesSrc = tilesSrc;
  }


  void addRow(){
    for (final row in state.tiles) {
      row.add(Tile.Grass);
    }
    refreshTileSize();
    resetTilesSrcDst();
  }

  void removeRow(){
    state.tiles.removeLast();
    refreshTileSize();
    resetTilesSrcDst();
  }

  void addColumn() {
    for (int i = 0; i < state.tiles.length; i++) {
      state.tiles[i].removeLast();
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
    final amount = modules.isometric.state.time.value - secondsPerHour;
    if (amount > 0) {
      modules.isometric.state.time.value = amount;
    } else {
      modules.isometric.state.time.value = secondsPerDay + amount;
    }
  }

  void addHour(){
    modules.isometric.state.time.value += secondsPerHour;
  }
}