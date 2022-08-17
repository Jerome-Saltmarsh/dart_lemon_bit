
import 'package:bleed_common/library.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';
import 'package:lemon_engine/render_single_atlas.dart';

import '../../map_atlas.dart';

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

    if (!init) {
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
    renderPlayerDot(canvas);
    // cameraCenter(mapTileActive.renderX, mapTileActive.renderY);
  }

  void renderPlayerDot(Canvas canvas) {
    final playerPerX = player.x / (tileSize * gridTotalRows);
    final playerPerY = player.y / (tileSize * gridTotalColumns);

    final playerX = (mapTileActive.x + playerPerX);
    final playerY = (mapTileActive.y + playerPerY);

    final renderX = ((playerX * mapTileSize) - (playerY * mapTileSize)) * 0.5;
    final renderY = (((playerX * mapTileSize) + (playerY * mapTileSize)) * 0.5) - mapTileSizeHalf;

    cameraCenter(renderX, renderY);

    canvasRenderAtlas(
      canvas: canvas,
      atlas: mapAtlas,
      srcX: 92,
      srcY: 28,
      srcWidth: 8,
      srcHeight: 8,
      dstX: renderX,
      dstY: renderY,
    );
  }

  void snapCameraToTarget() {
    final playerPerX = player.x / (tileSize * gridTotalRows);
    final playerPerY = player.y / (tileSize * gridTotalColumns);
    final playerX = (mapTileActive.x + playerPerX);
    final playerY = (mapTileActive.y + playerPerY);
    final renderX = ((playerX * mapTileSize) - (playerY * mapTileSize)) * 0.5;
    final renderY = (((playerX * mapTileSize) + (playerY * mapTileSize)) * 0.5) - mapTileSizeHalf;
    cameraCenter(renderX, renderY);
    cameraX = cameraXTarget;
    cameraY = cameraYTarget;
  }

  void cameraCenter(double x, double y){
    cameraXTarget = x - (screenCenterX / zoom);
    cameraYTarget = y - (screenCenterY / zoom);
  }
}