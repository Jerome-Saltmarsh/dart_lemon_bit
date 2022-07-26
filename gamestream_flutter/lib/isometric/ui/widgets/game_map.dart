
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';
import 'package:lemon_engine/state/paint.dart';

class GameMapWidget extends StatelessWidget {
  var screenCenterX = 0.0;
  var screenCenterY = 0.0;
  var zoom = 1.0;
  var cameraX = 0.0;
  var cameraY = 0.0;

  final double width;
  final double height;

  GameMapWidget(this.width, this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: buildCanvas(paint: renderCanvasMap, frame: canvasFrameMap),
    );
  }

  void renderCanvasMap(Canvas canvas, Size size) {
    screenCenterX = size.width * 0.5;
    screenCenterY = size.height * 0.5;
    // canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), paint);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // canvas.clipRRect(RRect.fromRectXY(Rect.fromLTWH(0, 0, size.width, size.height), size.width * 0.5, size.height * 0.5));
    canvas.scale(zoom);
    canvas.translate(-cameraX, -cameraY);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    // canvas.clipRRect(RRect.fromLTRBAndCorners(0, 0, 100, 100));
    for (final mapTile in mapTiles){
      renderMapTile(canvas, mapTile);
    }
    renderMapTile(canvas, mapTileActive);
    cameraCenter(mapTileActive.renderX, mapTileActive.renderY);
  }

  void cameraCenter(double x, double y){
    cameraX = x - (screenCenterX / zoom);
    cameraY = y - (screenCenterY / zoom);
  }
}