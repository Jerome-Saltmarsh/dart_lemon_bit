import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/tilesSrc.dart';
import 'package:bleed_client/state/game.dart';

const _size = 48.0;

void applyDynamicShadeToTileSrc() {
  int i = 0;
  final dynamicShading = modules.isometric.state.dynamicShading;
  for (int row = 0; row < game.totalRows; row++) {
    for (int column = 0; column < game.totalColumns; column++) {
      Shade shade = dynamicShading[row][column];
      tilesSrc[i + 1] = atlas.tiles.y + shade.index * _size; // top
      tilesSrc[i + 3] = tilesSrc[i + 1] + _size; // bottom
      i += 4;
    }
  }
}
