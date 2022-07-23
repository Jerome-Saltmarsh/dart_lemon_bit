
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/map_atlas.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_engine/state/paint.dart';
import 'dart:ui' as ui;
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
          buildCanvas(paint: renderCanvasMap, frame: canvasFrameMap)
        ],
      ),
    ),
  );
}

void renderCanvasMap(Canvas canvas, Size size){

  for (final mapTile in mapTiles){
    canvasRenderAtlas(
      canvas: canvas,
      atlas: mapAtlas,
      srcX: mapTileSize * mapTile.srcIndex,
      srcY: 0,
      srcWidth: mapTileSize,
      srcHeight: mapTileSize,
      dstX: mapTile.renderX,
      dstY: mapTile.renderY,
    );
  }
}


final mapTiles = <MapTile>[
   MapTile(0, 0, MapTiles.Village), //
   MapTile(1, 0, MapTiles.Forest),
   MapTile(0, 1, MapTiles.College),
];

class MapTiles {
  static const Village = 0;
  static const Forest = 1;
  static const College = 2;
  static const Dark_Castle = 3;
}

class MapTile {
  final int x;
  final int y;
  final int srcIndex;

  double get renderX => ((x * mapTileSize) - (y * mapTileSize)) * 0.5;
  double get renderY => ((x * mapTileSize) + (y * mapTileSize)) * 0.5;

  MapTile(this.x, this.y, this.srcIndex);
}