import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/tilesSrc.dart';
import 'package:bleed_client/state/game.dart';

const _width = 48.0;

void calculateTileSrcRects() {
  int i = 0;
  for (int row = 0; row < game.totalRows; row++) {
    for (int column = 0; column < game.totalColumns; column++) {
      Shade shading = dynamicShading[row][column];
      tilesSrc[i + 1] = shading.index * _width; // top
      tilesSrc[i + 3] = tilesSrc[i + 1] + _width; // bottom
      i += 4;
    }
  }
}
