import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/tilesSrcRects.dart';

const _width = 48.0;

void calculateTileSrcRects() {
  int i = 0;
  for (int row = 0; row < game.totalRows; row++) {
    for (int column = 0; column < game.totalColumns; column++) {
      Shade shading = dynamicShading[row][column];
      tileSrcRects[i + 1] = shading.index * _width; // top
      tileSrcRects[i + 3] = tileSrcRects[i + 1] + _width; // bottom
      i += 4;
    }
  }
}
