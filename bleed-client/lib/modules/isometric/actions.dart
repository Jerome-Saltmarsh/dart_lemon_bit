import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/state/tileRects.dart';
import 'package:bleed_client/render/state/tileTransforms.dart';
import 'package:bleed_client/state/game.dart';

class IsometricActions {

  IsometricState get _state => modules.isometric.state;

  void applyDynamicShadeToTileSrc() {
    final _size = 48.0;
    int i = 0;
    final dynamicShading = _state.dynamicShading;
    for (int row = 0; row < game.totalRows; row++) {
      for (int column = 0; column < game.totalColumns; column++) {
        Shade shade = dynamicShading[row][column];
        _state.tilesSrc[i + 1] = atlas.tiles.y + shade.index * _size; // top
        _state.tilesSrc[i + 3] = _state.tilesSrc[i + 1] + _size; // bottom
        i += 4;
      }
    }
  }

  void setBakeMapToAmbientLight(){
    print("isometric.actions.setBakeMapToAmbientLight()()");
    _state.bakeMap.clear();
    for (int row = 0; row < game.totalRows; row++) {
      final List<Shade> _baked = [];
      _state.bakeMap.add(_baked);
      for (int column = 0; column < game.totalColumns; column++) {
        _baked.add(_state.ambient.value);
      }
    }
  }

  void setDynamicMapToAmbientLight(){
    print("isometric.actions.setDynamicMapToAmbientLight()");
    _state.dynamicShading.clear();
    for (int row = 0; row < game.totalRows; row++) {
      final List<Shade> _dynamic = [];
      modules.isometric.state.dynamicShading.add(_dynamic);
      for (int column = 0; column < game.totalColumns; column++) {
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
    setBakeMapToAmbientLight();
    setDynamicMapToAmbientLight();
    mapTilesToSrcAndDst();
  }

  void mapTilesToSrcAndDst() {
    print("mapTilesToSrcAndDst()");
    _processTileTransforms();
    _loadTileRects();

    final total = tileRects.length * 4;
    final tilesDst = Float32List(total);
    final tilesSrc = Float32List(total);
    final tileSize = 48;
    final tileSizeHalf = tileSize / 2;

    for (int i = 0; i < tileRects.length; ++i) {
      final int index0 = i * 4;
      final int index1 = index0 + 1;
      final int index2 = index0 + 2;
      final int index3 = index0 + 3;
      final RSTransform rstTransform = tileTransforms[i];
      final Rect rect = tileRects[i];
      tilesDst[index0] = rstTransform.scos;
      tilesDst[index1] = rstTransform.ssin;
      tilesDst[index2] = rstTransform.tx;
      tilesDst[index3] = rstTransform.ty + tileSizeHalf;
      tilesSrc[index0] = atlas.tiles.x + rect.left;
      tilesSrc[index1] = atlas.tiles.y;
      tilesSrc[index2] = tilesSrc[index0] + tileSize;
      tilesSrc[index3] = tilesSrc[index1] + tileSize;
    }
    modules.isometric.state.tilesDst = tilesDst;
    modules.isometric.state.tilesSrc = tilesSrc;
  }

  void _processTileTransforms() {
    final tiles = game.tiles;
    tileTransforms.clear();
    for (int x = 0; x < tiles.length; x++) {
      for (int y = 0; y < tiles[0].length; y++) {
        tileTransforms.add(_buildTileRSTransform(x, y));
      }
    }
  }

  RSTransform _buildTileRSTransform(int x, int y) {
    return RSTransform.fromComponents(
        rotation: 0.0,
        scale: 1.0,
        anchorX: modules.isometric.constants.halfTileSize,
        anchorY: modules.isometric.constants.tileSize,
        translateX: getTileWorldX(x, y),
        translateY: getTileWorldY(x, y));
  }


  void _loadTileRects() {
    final tiles = game.tiles;
    tileRects.clear();
    for (int row = 0; row < tiles.length; row++) {
      for (int column = 0; column < tiles[0].length; column++) {
        tileRects.add(mapTileToSrcRect(tiles[row][column]));
      }
    }
  }

  void setTile({
    required int row,
    required int column,
    required Tile tile,
  }) {
    if (row < 0) return;
    if (column < 0) return;
    if (row >= game.totalRows) return;
    if (column >= game.totalColumns) return;
    if (game.tiles[row][column] == tile) return;
    game.tiles[row][column] = tile;
    modules.isometric.actions.mapTilesToSrcAndDst();
  }
}