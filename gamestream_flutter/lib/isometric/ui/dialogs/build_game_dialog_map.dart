
import 'package:bleed_common/map_tiles.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/map_atlas.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/screen.dart';
import '../../../flutterkit.dart';
import 'game_dialog_tab.dart';

final canvasFrameMap = ValueNotifier<int>(0);
const mapTileSize = 64.0;

Widget buildGameDialogMap(){
  return Container(
    width: screen.width,
    height: screen.height,
    alignment: Alignment.center,
    child: Container(
      color: brownLight,
      width: screen.width * goldenRatio_0618,
      height: screen.height * goldenRatio_0618,
      child: Column(
        children: [
          gameDialogTab,
          Container(
            height: screen.height * goldenRatio_0618 - 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCanvas(paint: renderCanvasMap, frame: canvasFrameMap),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

void renderCanvasMap(Canvas canvas, Size size){
  canvas.scale(1.5);
  for (final mapTile in mapTiles){
     renderMapTile(canvas, mapTile);
  }
  renderMapTile(canvas, mapTileActive);
}

void renderMapTile(Canvas canvas, MapTile value){
  canvasRenderAtlas(
    canvas: canvas,
    atlas: mapAtlas,
    srcX: mapTileSize * value.srcIndex,
    srcY: 0,
    srcWidth: mapTileSize,
    srcHeight: mapTileSize,
    dstX: value.renderX,
    dstY: value.renderY,
  );
}

final mapTileActive = MapTile(0, 0, MapTiles.Active);

final mapTiles = <MapTile>[
   MapTile(0, -1, MapTiles.Water),
   MapTile(-1, -1, MapTiles.Water),
   MapTile(-2, 0, MapTiles.Water),
   MapTile(0, -1, MapTiles.Water),
   MapTile(0, 0, MapTiles.Village),
   MapTile(1, 0, MapTiles.Forest),
   MapTile(-1, 0, MapTiles.Farm),
   MapTile(0, 1, MapTiles.FarmA),
   // MapTile(0, -1, MapTiles.Dark_Castle),
];

class MapTile {
  int x;
  int y;
  final int srcIndex;

  double get renderX => ((x * mapTileSize) - (y * mapTileSize)) * 0.5;
  double get renderY => ((x * mapTileSize) + (y * mapTileSize)) * 0.5;

  MapTile(this.x, this.y, this.srcIndex);
}