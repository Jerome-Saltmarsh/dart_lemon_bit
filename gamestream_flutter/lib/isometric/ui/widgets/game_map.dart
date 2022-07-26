
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';

class GameMapWidget extends StatelessWidget {
  var screenCenterX = 0.0;
  var screenCenterY = 0.0;
  var zoom = 1.0;
  var cameraX = 0.0;
  var cameraY = 0.0;
  var cameraXTarget = 0.0;
  var cameraYTarget = 0.0;

  final RRect? clipRRect;
  final double width;
  final double height;

  var clipRect = Rect.fromLTWH(0, 0, 0, 0);
  var init = false;

  GameMapWidget({required this.width, required this.height, this.clipRRect});

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

    if (!init){
      init = true;
      snapCameraToTarget();
    }

    const s = 0.05;
    cameraX += (cameraXTarget - cameraX) * s;
    cameraY += (cameraYTarget - cameraY) * s;

    if (clipRect.width != size.width || clipRect.height != size.height) {
       clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    }
    canvas.clipRect(clipRect);
    if (clipRRect != null){
      canvas.clipRRect(clipRRect!);
    }

    canvas.scale(zoom);
    canvas.translate(-cameraX, -cameraY);
    // canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    // canvas.clipRRect(RRect.fromLTRBAndCorners(0, 0, 100, 100));
    for (final mapTile in mapTiles){
      renderMapTile(canvas, mapTile);
    }
    renderMapTile(canvas, mapTileActive);
    cameraCenter(mapTileActive.renderX, mapTileActive.renderY);
  }

  void snapCameraToTarget() {
    cameraCenter(mapTileActive.renderX, mapTileActive.renderY);
    cameraX = cameraXTarget;
    cameraY = cameraYTarget;
  }

  void cameraCenter(double x, double y){
    cameraXTarget = x - (screenCenterX / zoom);
    cameraYTarget = y - (screenCenterY / zoom);
  }
}