

import 'dart:typed_data';

import 'package:gamestream_server/common/src/fight2d/game_fight2d_node_type.dart';

import 'game_fight2d_scene.dart';


class GameFight2DSceneGenerator {

  static GameFight2DScene generate(){
    final width = 50;
    final height = 20;
    final tiles = Uint8List(width * height);

    int getIndex(int x, int y) => x * height + y;

    void setTile({required int x, required int y, required int type}){
      if (x < 0) return;
      if (x >= width) return;
      if (y < 0) return;
      if (y >= height) return;
      tiles[getIndex(x, y)] = type;
    }

    void drawRectangle({
      required int x,
      required int y,
      required int width,
      required int height,
      required int type,
    }){
      for (var xIndex = 0; xIndex < width; xIndex++) {
        for (var yIndex = 0; yIndex < height; yIndex++) {
          setTile(
            x: x + xIndex,
            y: y + yIndex,
            type: type,
          );
        }
      }
    }

    drawRectangle(
      x: 10,
      y: 7,
      width: 10,
      height: 2,
      type: GameFight2DNodeType.Grass,
    );

    drawRectangle(x: 0, y: height - 3, width: width, height: 3, type: GameFight2DNodeType.Grass);
    drawRectangle(x: 5, y: height - 3, width: 8, height: 3, type: GameFight2DNodeType.Empty);
    drawRectangle(x: 6, y: height - 7, width: 6, height: 2, type: GameFight2DNodeType.Grass);
    drawRectangle(x: 25, y: height - 12, width: 12, height: 3, type: GameFight2DNodeType.Grass);
    drawRectangle(x: 40, y: height - 15, width: 10, height: 2, type: GameFight2DNodeType.Grass);

    drawRectangle(x: 35, y: height - 20, width: 5, height: 2, type: GameFight2DNodeType.Grass);

    return GameFight2DScene(tiles: tiles, width: width, height: height);
  }
}