
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/game_map.dart';
import 'package:gamestream_flutter/services/mini_map.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';

import '../../../game_widgets.dart';
import 'game_dialog_tab.dart';

final canvasFrameMap = ValueNotifier<int>(0);
const mapTileSize = 64.0;
const mapTileSizeHalf = mapTileSize / 2;



Widget buildGameDialogMap(){
  MiniMap.mapScreenCenterX = Engine.screen.width / 2;
  MiniMap.mapScreenCenterY = Engine.screen.height / 2;
  return Container(
    width: Engine.screen.width,
    height: Engine.screen.height,
    alignment: Alignment.center,
    child: Container(
      color: brownLight,
      width: Engine.screen.width * goldenRatio_0618,
      height: Engine.screen.height * goldenRatio_0618,
      child: Column(
        children: [
          watch(GameState.player.gameDialog, buildGameDialog),
          GameMapWidget(width: Engine.screen.width * goldenRatio_0618, height: Engine.screen.height * goldenRatio_0618 - 50),
        ],
      ),
    ),
  );
}





class MapTile {
  int x;
  int y;
  final int srcIndex;

  double get renderX => ((x * mapTileSize) - (y * mapTileSize)) * 0.5;
  double get renderY => ((x * mapTileSize) + (y * mapTileSize)) * 0.5;

  MapTile(this.x, this.y, this.srcIndex);
}
