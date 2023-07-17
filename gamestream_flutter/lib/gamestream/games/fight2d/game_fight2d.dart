import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d_ui.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_fight2d_player.dart';


class GameFight2D extends Game {
  static const length = 1000;
  static const Default_Camera_Zoom = 0.5;

  final renderCharacterState = WatchBool(false);

  final characterState = Uint8List(length);
  final characterDirection = Uint8List(length);
  final characterDamage = Uint16List(length);
  final characterStateDuration = Uint8List(length);
  final characterPositionX = Float32List(length);
  final characterPositionY = Float32List(length);
  final characterIsBot = List.generate(length, (index) => false, growable: false);

  var charactersTotal = 0;
  var sceneWidth = 0;
  var sceneHeight = 0;
  var sceneNodes = Uint8List(0);

  final player = GameFight2DPlayer();

  int get sceneTotal => sceneWidth * sceneHeight;

  GameFight2D();

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

         if (nodeType == GameFight2DNodeType.Empty){
           continue;
         }

         final srcY = <int, double>{
           GameFight2DNodeType.Empty: 0,
           GameFight2DNodeType.Grass: 34,
         }[nodeType] ?? 0;

         gamestream.engine.renderSprite(
             image: Images.atlas_fight2d_nodes,
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
    for (var i = 0; i < charactersTotal; i++){
      const frameSize = 256.0;
      const runFrames = [3, 4, 5, 6];
      const framesStrike = [27, 28, 29, 30];
      const framesJump = [26, 8];
      const framesCrouchingStrike = [31, 32, 33];
      const airbornStrikeDown = [15, 16];
      const airbornStrikeUp = [34, 35, 36, 37, 38, 39, 40];
      const framesRolling = [20, 21, 22, 23, 24, 0];
      final stateDuration = characterStateDuration[i];
      final animationFrame = stateDuration ~/ 5;
      final animationFrame2 = stateDuration ~/ 2;
      final state = characterState[i];

      final frame = switch (state) {
          GameFight2DCharacterState.Idle => 0,
          GameFight2DCharacterState.Running => runFrames[animationFrame % 4],
          GameFight2DCharacterState.Striking => capIndex(framesStrike, animationFrame2),
          GameFight2DCharacterState.Running_Strike => 7,
          GameFight2DCharacterState.Jumping => capIndex(framesJump, animationFrame),
          GameFight2DCharacterState.Airborn_Strike => 9,
          GameFight2DCharacterState.Crouching => 10,
          GameFight2DCharacterState.Striking_Up => 11,
          GameFight2DCharacterState.Hurting => 12,
          GameFight2DCharacterState.Hurting_Airborn => 13,
          GameFight2DCharacterState.Airborn_Movement => 14,
          GameFight2DCharacterState.Idle_Airborn => 14,
          GameFight2DCharacterState.Second_Jump => capIndex(framesJump, animationFrame),
          GameFight2DCharacterState.Fall_Fast => 14,
          GameFight2DCharacterState.Crouching_Strike => capIndex(framesCrouchingStrike, animationFrame2),
          GameFight2DCharacterState.Airborn_Strike_Down => capIndex(airbornStrikeDown, animationFrame),
          GameFight2DCharacterState.Airborn_Strike_Up => capIndex(airbornStrikeUp, animationFrame2),
          GameFight2DCharacterState.Rolling => capIndex(framesRolling, animationFrame),
          _ => 0
      };

      gamestream.engine.renderSprite(
          image: Images.atlas_fight2d_character,
          srcX: frame * frameSize,
          srcY:  characterDirection[i] == GameFight2DDirection.Left ? 0 : frameSize,
          srcWidth: frameSize,
          srcHeight: frameSize,
          dstX: characterPositionX[i].toDouble(),
          dstY: characterPositionY[i].toDouble() - 12,
      );

      if (renderCharacterState.value){
        gamestream.engine.renderText(
          GameFight2DCharacterState.getName(state),
          characterPositionX[i].toDouble(),
          characterPositionY[i].toDouble() - 100,
        );
      }

      gamestream.engine.paint.color = Colors.white;
      gamestream.engine.renderText(
          characterIsBot[i] ? '${characterDamage[i]}-AI' : characterDamage[i].toString(),
        characterPositionX[i].toDouble() - 20,
        characterPositionY[i].toDouble() - 120,
        style: damageTextStyle,
      );
    }
  }

  final damageTextStyle = TextStyle(
      fontSize: 28,
      color: Colors.white,
      fontWeight: FontWeight.bold,
  );

  @override
  void renderForeground(Canvas canvas, Size size) {

  }

  @override
  void update() {
    gamestream.io.applyKeyboardInputToUpdateBuffer();
    gamestream.io.sendUpdateBuffer();
    gamestream.engine.cameraFollow(player.x, player.y);
  }

  void applyCharacterAudio() {
    for (var i = 0; i < charactersTotal; i++){
       if (characterState[i] == GameFight2DCharacterState.Running){
          if (characterStateDuration[i] % 8 == 0){
            gamestream.audio.playAudioSingle2D(
                gamestream.audio.footstep_grass_7,
                characterPositionX[i],
                characterPositionY[i],
            );
          }
       }
    }
  }

  void updateCamera() {
    const speed = 4.0;
    if (gamestream.engine.keyPressed(KeyCode.Arrow_Up)){
      gamestream.engine.cameraY -= speed;
    }
    if (gamestream.engine.keyPressed(KeyCode.Arrow_Down)){
      gamestream.engine.cameraY += speed;
    }
    if (gamestream.engine.keyPressed(KeyCode.Arrow_Left)){
      gamestream.engine.cameraX -= speed;
    }
    if (gamestream.engine.keyPressed(KeyCode.Arrow_Right)){
      gamestream.engine.cameraX += speed;
    }
  }

  @override
  void onActivated() {
    gamestream.engine.zoom = Default_Camera_Zoom;
    gamestream.engine.targetZoom = gamestream.engine.zoom;
  }

  @override
  Widget buildUI(BuildContext context) => GameFight2DUI(this);

  void togglePlayerEdit() =>
      gamestream.network.sendClientRequest(
          ClientRequest.Fight2D,
          GameFight2DClientRequest.Toggle_Player_Edit,
      );
}

