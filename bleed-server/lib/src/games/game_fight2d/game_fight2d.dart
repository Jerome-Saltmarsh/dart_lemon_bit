
import 'package:bleed_server/common/src/fight2d/game_fight2d_events.dart';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/game_fight2d/game_fight2d_bot.dart';
import 'package:bleed_server/src/games/game_fight2d/game_fight2d_scene.dart';
import 'package:lemon_math/functions/random_between.dart';

import 'game_fight2d_character.dart';
import 'game_fight2d_player.dart';

class GameFight2D extends Game<GameFight2DPlayer> {

  final characters = <GameFight2DCharacter>[];
  final GameFight2DScene scene;

  GameFight2D({required this.scene}) : super(gameType: GameType.Fight2D) {
    characters.add(
      GameFight2DBot()
        ..x = 100
        ..y = 200
    );
  }

  @override
  GameFight2DPlayer createPlayer() {
    final player = GameFight2DPlayer(this);
    player.writeScene();
    player.x = randomBetween(0, scene.widthLength);
    player.y = 0;
    characters.add(player);
    return player;
  }

  @override
  void onPlayerUpdateRequestReceived({
    required GameFight2DPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
     player.jumpingRequested = mouseRightDown;
     player.directionRequested = direction;

     if (keySpaceDown || mouseLeftDown) {
       player.strike();
     }


     switch (direction) {
       case InputDirection.Right:
         player.runRight();
         break;
       case InputDirection.Up_Right:
         player.jump();
         break;
       case InputDirection.Up_Left:
         player.jump();
         break;
       case InputDirection.Left:
         player.runLeft();
         break;
       case InputDirection.Up:
         player.jump();
         break;
       case InputDirection.Down:
         player.crouch();
         break;
       case InputDirection.Down_Right:
         player.crouch();
         break;
       case InputDirection.Down_Left:
         player.crouch();
         break;
       case InputDirection.None:
         player.idle();
         break;
     }
  }

  @override
  void removePlayer(GameFight2DPlayer player) {
    characters.remove(player);
  }

  @override
  void update() {
    updateCharacters();
  }

  void emitEventJump(GameFight2DCharacter character) {
    if (!character.emitEventJump) return;
    character.emitEventJump = false;
    emitEvent(character: character, event: GameFight2DEvents.Jump);
  }

  void emitEventPunch(GameFight2DCharacter character) {
    emitEvent(character: character, event: GameFight2DEvents.Punch);
  }

  void emitEvent({
    required GameFight2DCharacter character,
    required int event,
  }){
    final xInt = character.x.toInt();
    final yInt = character.y.toInt();
    for (final player in players) {
      player.writeEvent(event: event, x: xInt, y: yInt);
    }
  }

  void updateCharacters() {
    for (final character in characters) {
      character.update();
      applyCharacterSceneCollision(character);
      emitEventJump(character);

      if (character.running && character.stateDuration % 6 == 0) {
         emitEvent(character: character, event: GameFight2DEvents.Footstep);
      }

      applyCharacterStrike(character);
    }
  }

  void applyCharacterStrike(GameFight2DCharacter character) {
    if (character.stateDuration != character.strikeFrame) return;

    switch (character.state){
      case GameFight2DCharacterState.Striking:
        applyCharacterHitBoxStrike(character);
        break;
      case GameFight2DCharacterState.Striking_Up:
        applyCharacterHitBoxStrikeUp(character);
        break;
      case GameFight2DCharacterState.Airborn_Strike:
        applyCharacterHitBoxAirbornStrike(character);
        break;
      case GameFight2DCharacterState.Running_Strike:
        applyCharacterHitBoxStrike(character);
        break;
      case GameFight2DCharacterState.Crouching_Strike:
        applyCharacterHitBoxStrike(character);
        break;
    }
  }

  void applyCharacterHitBoxStrike(GameFight2DCharacter character){
    if (character.stateDuration != character.strikeFrame) return;
    emitEventPunch(character);
    for (final otherCharacter in characters){
      const rangeX = 75.0;
      const rangeY = 75.0;

      if (otherCharacter == character) continue;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (rangeY < yDiff.abs()) continue;

      const force = 10.0;
      if (character.facingLeft){
        if (xDiff > 0 && xDiff < rangeX) {
          if (character.state == GameFight2DCharacterState.Running_Strike){
            otherCharacter.hurtAirborn();
            otherCharacter.accelerationY -= force;
          } else {
            otherCharacter.hurt();
          }
          otherCharacter.accelerationX -= force;
        }
      } else {
        if (xDiff < rangeX) {
          switch (character.state) {
            case GameFight2DCharacterState.Running_Strike:
              otherCharacter.hurtAirborn();
              otherCharacter.accelerationY -= force;
              break;
            default:
              otherCharacter.hurt();
              break;
          }
          if (character.state == GameFight2DCharacterState.Running_Strike) {
            otherCharacter.hurtAirborn();
            otherCharacter.accelerationY -= force;
          } else {
            otherCharacter.hurt();
          }
          otherCharacter.accelerationX += force;
        }
      }
    }
  }

  void applyCharacterHitBoxStrikeUp(GameFight2DCharacter character){
       if (character.stateDuration != 5) return;
       for (final otherCharacter in characters) {
           if (otherCharacter == character) continue;
           const rangeX = 75.0;
           const rangeY = 75.0;
           final xDiff = character.x - otherCharacter.x;
           if (rangeX < xDiff.abs()) continue;
           final yDiff = character.y - otherCharacter.y;
           if (rangeY < yDiff.abs()) continue;
           otherCharacter.hurtAirborn();
           otherCharacter.accelerationY -= 20;
           emitEventPunch(character);
       }
  }

  void applyCharacterHitBoxAirbornStrike(GameFight2DCharacter character){
       if (character.stateDuration != 5) return;
       for (final otherCharacter in characters) {
           if (otherCharacter == character) continue;
           const rangeX = 75.0;
           const rangeY = 75.0;
           final xDiff = character.x - otherCharacter.x;
           if (rangeX < xDiff.abs()) continue;
           final yDiff = character.y - otherCharacter.y;
           if (rangeY < yDiff.abs()) continue;
           otherCharacter.hurtAirborn();
           otherCharacter.accelerationY -= 20;
           otherCharacter.accelerationX += character.facingLeft ? -10 : 10;
           emitEventPunch(character);
       }
  }

  void applyCharacterSceneCollision(GameFight2DCharacter character) {
       var tileType = scene.getTileTypeAtXY(character.x, character.y + 50.0);
       if (tileType == Fight2DNodeType.Grass) {
         if (!character.grounded) {
           onGrounded(character);
         }
         while (scene.getTileTypeAtXY(character.x, character.y + 49.0) == Fight2DNodeType.Grass){
            character.y--;
         }
         if (character.velocityY > 0) {
           character.velocityY = 0;
         }
       } else {
         character.grounded = false;
       }
  }


  /// EVENT HANDLER (DO NOT CALL)
  void onGrounded(GameFight2DCharacter character) {
    character.grounded = true;
    character.jumpCount = 0;
    character.forceIdle();
  }
}


