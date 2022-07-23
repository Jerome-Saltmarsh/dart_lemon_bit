
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
  canvasRenderAtlas(
    canvas: canvas,
    atlas: mapAtlas,
    srcX: 0,
    srcY: 0,
    srcWidth: 64,
    srcHeight: 64,
    dstX: 50,
    dstY: 50,
  );
}


final mapTiles = <MapTile> [];

class MapTile {
  final int x;
  final int y;
  late Offset offset;
  MapTile(this.x, this.y) {
    offset = Offset(x * 10, y * 10);
  }
}