import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/draw.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/state/tileRects.dart';
import 'package:bleed_client/render/state/tileTransforms.dart';
import 'package:bleed_client/render/state/tilesDst.dart';
import 'package:bleed_client/render/state/tilesSrc.dart';
import 'package:bleed_client/state/game.dart';

void mapTilesToSrcAndDst() {
  print("mapTilesToSrcAndDst()");
  _processTileTransforms();
  _loadTileRects();

  int total = tileRects.length * 4;
  final tilesDst = Float32List(total);
  tilesSrc = Float32List(total);

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
    tilesDst[index3] = rstTransform.ty + 24;
    tilesSrc[index0] = atlas.tiles.x + rect.left;
    tilesSrc[index1] = atlas.tiles.y;
    tilesSrc[index2] = tilesSrc[index0] + 48;
    tilesSrc[index3] = tilesSrc[index1] + 48;
  }

  modules.isometric.state.tilesDst = tilesDst;
}

void _processTileTransforms() {
  final tiles = game.tiles;
  tileTransforms.clear();
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      tileTransforms.add(getTileTransform(x, y));
    }
  }
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
