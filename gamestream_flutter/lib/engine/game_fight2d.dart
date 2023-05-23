

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

import 'game.dart';

class GameFight2D extends Game {
  static var playerX = 0.0;
  static var playerY = 0.0;
  static var playerState = GameFight2DCharacterState.Idle;
  static const length = 1000;
  static var characters = 0;
  static final characterState = Uint8List(length);
  static final characterDirection = Uint8List(length);
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
      const frameSize = 256.0;
      const runFrames = [3, 4, 5, 6];
      const framesStrike = [1, 2];
      final stateDuration = characterStateDuration[i];
      final animationFrame = stateDuration ~/ 5;
      final state = characterState[i];

      final frame = switch (state) {
          GameFight2DCharacterState.Idle => 0,
          GameFight2DCharacterState.Running => runFrames[animationFrame % 4],
          GameFight2DCharacterState.Striking => capIndex(framesStrike, animationFrame),
          GameFight2DCharacterState.Running_Strike => 7,
          GameFight2DCharacterState.Jumping => 8,
          _ => 0
      };

      Engine.renderSprite(
          image: GameImages.atlas_fight2d_character,
          srcX: frame * frameSize,
          srcY:  characterDirection[i] == GameFight2DDirection.Left ? 0 : frameSize,
          srcWidth: frameSize,
          srcHeight: frameSize,
          dstX: characterPositionX[i].toDouble(),
          dstY: characterPositionY[i].toDouble() - 12,
      );

      Engine.renderText(
          GameFight2DCharacterState.getName(state),
          characterPositionX[i].toDouble(),
          characterPositionY[i].toDouble() - 100,
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

