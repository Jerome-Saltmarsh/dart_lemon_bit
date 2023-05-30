
import 'dart:typed_data';

import 'package:bleed_server/src/games/game_fight2d/game_fight2d_scene.dart';

import 'game_fight2d_node_type.dart';

class GameFight2DSceneGenerator {

  static GameFight2DScene generate(){
    final width = 40;
    final height = 20;
    final tiles = Uint8List(width * height);
    for (var x = 0; x < width; x++) {
      if (x > 5 && x < 8) continue;
      for (var y = 0; y < height; y++) {
        final index = x * height + y;
        tiles[index] = y > height - 3
            ? GameFight2DNodeType.Grass
            : GameFight2DNodeType.Empty;
      }
    }
    return GameFight2DScene(tiles: tiles, width: width, height: height);
  }
}