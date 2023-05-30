import 'dart:typed_data';

import 'package:bleed_server/common/src.dart';

class GameFight2DScene {
  static const tileSize = 32.0;

  int width;
  int height;
  late double widthLength;
  late double heightLength;

  late Uint8List tiles;

  GameFight2DScene({required this.tiles, required this.width, required this.height}) {
    this.widthLength = width * tileSize;
    this.heightLength = height * tileSize;
  }

  int getTileTypeAtXY(double x, double y) {
    if (x < 0 || y < 0) {
      return GameFight2DNodeType.Out_Of_Bounds;
    }
    if (x > widthLength || y > heightLength) {
      return GameFight2DNodeType.Out_Of_Bounds;
    }

    final nodeX = x ~/ tileSize;
    final nodeY = y ~/ tileSize;
    return tiles[nodeX * height + nodeY];
  }
}
