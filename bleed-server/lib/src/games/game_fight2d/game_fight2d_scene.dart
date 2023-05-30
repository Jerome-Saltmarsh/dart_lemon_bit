import 'dart:typed_data';

import 'package:bleed_server/common/src.dart';

class GameFight2DScene {
  static const tileSize = 32.0;

  int width;
  int height;
  /// width * nodeSIze
  late double widthLength;
  /// height * nodeSize
  late double heightLength;

  late Uint8List tiles;

  GameFight2DScene({required this.width, required this.height}) {
    tiles = Uint8List(width * height);
    this.widthLength = width * tileSize;
    this.heightLength = height * tileSize;

    var index = 0;
    for (var x = 0; x < width; x++){
      for (var y = 0; y < height; y++){
        tiles[index] = y > height - 3 ? GameFight2DNodeType.Grass : GameFight2DNodeType.Empty;
        index++;
      }
    }
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
