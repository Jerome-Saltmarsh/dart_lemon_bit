import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d_ui.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/bool_watch_builder_checkbox.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_fight2d_player.dart';


class GameFight2D extends Game {
  static const length = 1000;

  final renderCharacterState = WatchBool(false);

  final characterState = Uint8List(length);
  final characterDirection = Uint8List(length);
  final characterDamage = Uint16List(length);
  final characterStateDuration = Uint8List(length);
  final characterPositionX = Float32List(length);
  final characterPositionY = Float32List(length);

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

         final srcY = <int, double>{
           GameFight2DNodeType.Empty: 0,
           GameFight2DNodeType.Grass: 34,
         }[nodeType] ?? 0;

         engine.renderSprite(
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
    for (var i = 0; i < charactersTotal; i++){
      const frameSize = 256.0;
      const runFrames = [3, 4, 5, 6];
      const framesStrike = [1, 2];
      const airbornStrikeDown = [15, 16];
      const airbornStrikeUp = [17, 18];
      const framesRolling = [20, 21, 22, 23, 24, 0];
      final stateDuration = characterStateDuration[i];
      final animationFrame = stateDuration ~/ 5;
      final state = characterState[i];

      final frame = switch (state) {
          GameFight2DCharacterState.Idle => 0,
          GameFight2DCharacterState.Running => runFrames[animationFrame % 4],
          GameFight2DCharacterState.Striking => capIndex(framesStrike, animationFrame),
          GameFight2DCharacterState.Running_Strike => 7,
          GameFight2DCharacterState.Jumping => 8,
          GameFight2DCharacterState.Airborn_Strike => 9,
          GameFight2DCharacterState.Crouching => 10,
          GameFight2DCharacterState.Striking_Up => 11,
          GameFight2DCharacterState.Hurting => 12,
          GameFight2DCharacterState.Hurting_Airborn => 13,
          GameFight2DCharacterState.Airborn_Movement => 14,
          GameFight2DCharacterState.Idle_Airborn => 14,
          GameFight2DCharacterState.Second_Jump => 8,
          GameFight2DCharacterState.Fall_Fast => 14,
          GameFight2DCharacterState.Crouching_Strike => 19,
          GameFight2DCharacterState.Airborn_Strike_Down => capIndex(airbornStrikeDown, animationFrame),
          GameFight2DCharacterState.Airborn_Strike_Up => capIndex(airbornStrikeUp, animationFrame),
          GameFight2DCharacterState.Rolling => capIndex(framesRolling, animationFrame),
          _ => 0
      };

      engine.renderSprite(
          image: GameImages.atlas_fight2d_character,
          srcX: frame * frameSize,
          srcY:  characterDirection[i] == GameFight2DDirection.Left ? 0 : frameSize,
          srcWidth: frameSize,
          srcHeight: frameSize,
          dstX: characterPositionX[i].toDouble(),
          dstY: characterPositionY[i].toDouble() - 12,
      );

      if (renderCharacterState.value){
        engine.renderText(
          GameFight2DCharacterState.getName(state),
          characterPositionX[i].toDouble(),
          characterPositionY[i].toDouble() - 100,
        );
      }

      engine.renderText(
        characterDamage[i].toString(),
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
    gamestream.network.sendClientRequestUpdate();
    engine.cameraFollow(player.x, player.y);
    // applyCharacterAudio();
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
    if (engine.keyPressed(KeyCode.Arrow_Up)){
      engine.cameraY -= speed;
    }
    if (engine.keyPressed(KeyCode.Arrow_Down)){
      engine.cameraY += speed;
    }
    if (engine.keyPressed(KeyCode.Arrow_Left)){
      engine.cameraX -= speed;
    }
    if (engine.keyPressed(KeyCode.Arrow_Right)){
      engine.cameraX += speed;
    }
  }

  @override
  void onActivated() {
    engine.zoom = 1.0;
    engine.targetZoom = 1.0;
  }

  @override
  Widget buildUI(BuildContext context) => GameFight2DUI(this);

  void togglePlayerEdit() =>
      gamestream.network.sendClientRequest(
          ClientRequest.Fight2D,
          GameFight2DClientRequest.Toggle_Player_Edit,
      );
}

