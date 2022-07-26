
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

final mapTiles = <MapTile> [
   MapTile(-2, -1, MapTiles.Water),
   MapTile(-2, 0, MapTiles.Water),
   MapTile(-2, 1, MapTiles.Water),
   MapTile(-2, 2, MapTiles.Water),
   MapTile(-2, 3, MapTiles.Water),
   MapTile(-1, -1, MapTiles.Water),
   MapTile(-1, 0, MapTiles.Farm),
   MapTile(-1, 1, MapTiles.FarmB),
   MapTile(-1, 2, MapTiles.Mountain_Shrine),
   MapTile(-1, 3, MapTiles.Town),
   MapTile(-1, 4, MapTiles.Water),
   MapTile(0, -2, MapTiles.Water),
   MapTile(0, -1, MapTiles.Water),
   MapTile(0, 0, MapTiles.Village),
   MapTile(0, 1, MapTiles.FarmA),
   MapTile(0, 2, MapTiles.Lake),
   MapTile(0, 3, MapTiles.Plains_1),
   MapTile(0, 4, MapTiles.Plains_3),
   MapTile(1, -2, MapTiles.Water),
   MapTile(1, -1, MapTiles.ForestB),
   MapTile(1, 0, MapTiles.Forest),
   MapTile(1, 1, MapTiles.Mountains_1),
   MapTile(1, 2, MapTiles.Mountains_2),
   MapTile(1, 3, MapTiles.Plains_2),
   MapTile(1, 4, MapTiles.Outpost_1),
   MapTile(2, -1, MapTiles.Forest_3),

];

class MapTile {
  int x;
  int y;
  final int srcIndex;

  double get renderX => ((x * mapTileSize) - (y * mapTileSize)) * 0.5;
  double get renderY => ((x * mapTileSize) + (y * mapTileSize)) * 0.5;

  MapTile(this.x, this.y, this.srcIndex);
}