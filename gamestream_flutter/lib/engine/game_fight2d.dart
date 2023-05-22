

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

import 'game.dart';


class GameFight2D extends Game {
  static var playerX = 0.0;
  static var playerY = 0.0;
  static var playerState = GameFight2DCharacterState.idle;
  static const length = 1000;
  static var characters = 0;
  static final characterState = Uint8List(length);
  static final characterStateDuration = Uint8List(length);
  static final characterPositionX = Float32List(length);
  static final characterPositionY = Float32List(length);

  static var sceneWidth = 0;
  static var sceneHeight = 0;
  static var sceneNodes = Uint8List(0);

  static int get sceneTotal => sceneWidth * sceneHeight;

  @override
  void drawCanvas(Canvas canvas, Size size) {
      renderTiles();
      renderCharacters();
  }

  void renderTiles() {
       var index = 0;
    for (var x = 0; x < sceneWidth; x++){
       for (var y = 0; y < sceneHeight; y++){
         final nodeType = sceneNodes[index];
         index++;

         final srcY = <int, double>{
           Fight2DNodeType.Empty: 0,
           Fight2DNodeType.Grass: 34,
         }[nodeType] ?? 0;

         Engine.renderSprite(
             image: GameImages.atlas_fight2d_nodes,
             srcX: srcY,
             srcY: 0,
             srcWidth: 34,
             srcHeight: 34,
             dstX: x * 32,
             dstY: y * 32,
         );

       }
    }
  }

  void renderCharacters() {
    for (var i = 0; i < characters; i++){
      final state = characterState[i];

      const frameSize = 256.0;
      const runFrames = <double>[
        3, 4, 5, 6
      ];
      final stateDuration = characterStateDuration[i];
      final animationFrame = stateDuration ~/ 5;

      final frame = switch (state) {
          GameFight2DCharacterState.idle => 0,
          GameFight2DCharacterState.runRight => runFrames[animationFrame % 4],
          GameFight2DCharacterState.runLeft => runFrames[animationFrame % 4],
          _ => 0
      };

      Engine.renderSprite(
          image: GameImages.atlas_fight2d_character,
          srcX: frame * frameSize,
          srcY: state == GameFight2DCharacterState.runRight ? frameSize : 0,
          srcWidth: frameSize,
          srcHeight: frameSize,
          dstX: characterPositionX[i].toDouble(),
          dstY: characterPositionY[i].toDouble(),
      );

    }
  }

  @override
  void renderForeground(Canvas canvas, Size size) {

  }

  @override
  void update() {
    GameNetwork.sendClientRequestUpdate();
    Engine.cameraFollow(playerX, playerY);
  }

  void updateCamera() {
    const speed = 4.0;
    if (Engine.keyPressed(KeyCode.Arrow_Up)){
      Engine.cameraY -= speed;
    }
    if (Engine.keyPressed(KeyCode.Arrow_Down)){
      Engine.cameraY += speed;
    }
    if (Engine.keyPressed(KeyCode.Arrow_Left)){
      Engine.cameraX -= speed;
    }
    if (Engine.keyPressed(KeyCode.Arrow_Right)){
      Engine.cameraX += speed;
    }
  }

  @override
  void onActivated() {
    Engine.zoom = 1.0;
    Engine.targetZoom = 1.0;
  }

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 16,
            right: 16,
            child: Text("FIGHT2D")
        )
      ],
    );
  }
}

