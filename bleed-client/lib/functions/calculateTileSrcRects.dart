import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/tilesRects.dart';
import 'package:bleed_client/state.dart';
import 'package:flutter/cupertino.dart';

void calculateTileSrcRects() {
  int i = 0;
  List<List<Tile>> _tiles = compiledGame.tiles;

  for (int row = 0; row < _tiles.length; row++) {
    for (int column = 0; column < _tiles[0].length; column++) {
      Shading shading = dynamicShading[row][column];

      if (shading == Shading.VeryDark) {
        tilesRects[i] = rectSrcDarkness.left;
        tilesRects[i + 2] = rectSrcDarkness.right;
        i += 4;
        continue;
      }

      Rect rect = mapTileToSrcRect(_tiles[row][column]);
      double left = rect.left;

      if (shading == Shading.Medium) {
        left += 48;
      } else if (shading == Shading.Dark) {
        left += 96;
      }

      tilesRects[i] = left;
      tilesRects[i + 2] = left + 48;
      i += 4;
    }
  }
}
