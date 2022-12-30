
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';
import 'package:gamestream_flutter/library.dart';

class MiniMap {

  static final mapTileActive = MapTile(0, 0, MapTiles.Active);

  static final mapTiles = <MapTile> [
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
    MapTile(-1, 5, MapTiles.Water),
    MapTile(-1, 6, MapTiles.Water),
    MapTile(0, -2, MapTiles.Water),
    MapTile(0, -1, MapTiles.Water),
    MapTile(0, 0, MapTiles.Village),
    MapTile(0, 1, MapTiles.FarmA),
    MapTile(0, 2, MapTiles.Lake),
    MapTile(0, 3, MapTiles.Plains_1),
    MapTile(0, 4, MapTiles.Plains_3),
    MapTile(0, 5, MapTiles.Shrine_1),
    MapTile(0, 6, MapTiles.Water),
    MapTile(1, -2, MapTiles.Water),
    MapTile(1, -1, MapTiles.ForestB),
    MapTile(1, 0, MapTiles.Forest),
    MapTile(1, 1, MapTiles.Mountains_1),
    MapTile(1, 2, MapTiles.Mountains_2),
    MapTile(1, 3, MapTiles.Plains_2),
    MapTile(1, 4, MapTiles.Outpost_1),
    MapTile(2, -2, MapTiles.Water),
    MapTile(2, -1, MapTiles.Forest_3),
    MapTile(2, 0, MapTiles.Forest_4),
    MapTile(2, 1, MapTiles.Mountains_3),
    MapTile(2, 2, MapTiles.Mountains_4),
    MapTile(2, 3, MapTiles.Plains_4),
    MapTile(3, -2, MapTiles.Water),
    MapTile(3, -1, MapTiles.Water),
  ];

  static var mapZoom = 1.0;
  static var mapCameraX = 0.0;
  static var mapCameraY = 0.0;
  static var mapScreenCenterX = 0.0;
  static var mapScreenCenterY = 0.0;

  static void mapCameraCenter(double x, double y){
    mapCameraX = x - (mapScreenCenterX / mapZoom);
    mapCameraY = y - (mapScreenCenterY / mapZoom);
  }

  static void renderCanvasMap(Canvas canvas, Size size){
    mapScreenCenterX = size.width * 0.5;
    mapScreenCenterY = size.height * 0.5;
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.scale(mapZoom);
    canvas.translate(-mapCameraX, -mapCameraY);
    for (final mapTile in mapTiles){
      renderMapTile(canvas, mapTile);
    }
    renderMapTile(canvas, mapTileActive);
    mapCameraCenter(mapTileActive.renderX, mapTileActive.renderY);
  }

  static void renderMapTile(Canvas canvas, MapTile value){
    Engine.renderExternalCanvas(
      canvas: canvas,
      image: GameImages.minimap,
      srcX: mapTileSize * value.srcIndex,
      srcY: 0,
      srcWidth: mapTileSize,
      srcHeight: mapTileSize,
      dstX: value.renderX,
      dstY: value.renderY,
    );
  }

  static Widget buildGameMap(double width, double height){
    return SizedBox(
      height: width,
      width: height,
      child: Engine.buildCanvas(paint: renderCanvasMap, frame: canvasFrameMap),
    );
  }

  static void onMapTileChanged(int value){
    for (final tile in mapTiles) {
      if (tile.srcIndex != value) continue;
      mapTileActive.x = tile.x;
      mapTileActive.y = tile.y;
    }
  }
}