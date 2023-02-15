
import 'package:flutter/cupertino.dart';

final canvasFrameMap = ValueNotifier<int>(0);
const mapTileSize = 64.0;
const mapTileSizeHalf = mapTileSize / 2;

class MapTile {
  int x;
  int y;
  final int srcIndex;

  double get renderX => ((x * mapTileSize) - (y * mapTileSize)) * 0.5;
  double get renderY => ((x * mapTileSize) + (y * mapTileSize)) * 0.5;

  MapTile(this.x, this.y, this.srcIndex);
}
