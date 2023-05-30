
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/game_fight2d/game_fight2d_bot.dart';
import 'package:bleed_server/src/games/game_fight2d/game_fight2d_scene.dart';
import 'package:lemon_math/functions/random_between.dart';

import 'game_fight2d_character.dart';
import 'game_fight2d_player.dart';

class GameFight2D extends Game<GameFight2DPlayer> {
  static const Boundary_Y = 1000;
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
    player.writePlayerEdit();
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
     if (keySpaceDown || mouseLeftDown) {
       switch (direction) {
         case InputDirection.Right:
           player.strike();
           break;
         case InputDirection.Up_Right:
           player.strikeUp();
           break;
         case InputDirection.Up_Left:
           player.strikeUp();
           break;
         case InputDirection.Left:
           player.strike();
           break;
         case InputDirection.Up:
           player.strikeUp();
           break;
         case InputDirection.Down:
           player.strikeDown();
           break;
         case InputDirection.Down_Right:
           player.strikeDown();
           break;
         case InputDirection.Down_Left:
           player.strikeDown();
           break;
         case InputDirection.None:
           player.strike();
           break;
       }
     }

     if (player.jumpingRequested) {
       player.jumpingRequested = const [
         InputDirection.Up,
         InputDirection.Up_Left,
         InputDirection.Up_Right,
       ].contains(direction);
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
         player.rollRight();
         break;
       case InputDirection.Down_Left:
         player.rollLeft();
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
      updateCharacter(character);
    }
  }

  void updateCharacter(GameFight2DCharacter character) {
    if (character.y > Boundary_Y) {
      emitEvent(character: character, event: GameFight2DEvents.Death);
      character.respawn();
    }

    character.update();
    applyCharacterSceneCollision(character);
    emitEventJump(character);

    if (character.running && character.stateDuration % 6 == 0) {
      emitEvent(character: character, event: GameFight2DEvents.Footstep);
    }

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
      case GameFight2DCharacterState.Airborn_Strike_Down:
        applyCharacterHitBoxAirbornStrikeDown(character);
        break;
      case GameFight2DCharacterState.Airborn_Strike_Up:
        applyCharacterHitBoxAirbornStrikeUp(character);
        break;
    }
  }

  void applyCharacterHitBoxStrike(GameFight2DCharacter character){
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;

    var strikeHit = false;
    for (final otherCharacter in characters){
      const rangeX = 75.0;
      const rangeY = 75.0;

      if (otherCharacter == character) continue;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (rangeY < yDiff.abs()) continue;
      var force = character.strikeDamage + otherCharacter.damageForce;
      if (character.facingLeft) {
        if (xDiff > 0 && xDiff < rangeX) {
          if (character.state == GameFight2DCharacterState.Running_Strike){
            otherCharacter.hurtAirborn();
            otherCharacter.accelerationY -= force;
            otherCharacter.damage += character.runningStrikeDamage;
          } else {
            otherCharacter.hurt();
            otherCharacter.damage += character.strikeDamage;
          }
          otherCharacter.accelerationX -= force;
          strikeHit = true;
        }
      } else {
        if (xDiff > 0) continue;
        if (xDiff < rangeX) {
          otherCharacter.accelerationX += force;
          switch (character.state) {
            case GameFight2DCharacterState.Running_Strike:
              otherCharacter.hurtAirborn();
              otherCharacter.accelerationY -= force;
              otherCharacter.damage += 5;
              strikeHit = true;
              break;
            default:
              otherCharacter.hurt();
              strikeHit = true;
              otherCharacter.damage += 5;
              break;
          }

        }
      }
    }

    if (strikeHit){
      emitEvent(character: character, event: GameFight2DEvents.Punch);
    }
  }

  void applyCharacterHitBoxStrikeUp(GameFight2DCharacter character){
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != 5) return;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      const rangeX = 75.0;
      const rangeY = 75.0;
      final force = 20 + otherCharacter.damage;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (rangeY < yDiff.abs()) continue;
      otherCharacter.hurtAirborn();
      otherCharacter.accelerationY -= force;
      otherCharacter.damage += 5;
      emitEventPunch(character);
    }
  }

  void emitCharacterStrikeSwing(GameFight2DCharacter character){
    if (character.stateDuration != character.strikeSwingFrame) return;
    emitEvent(character: character, event: GameFight2DEvents.Strike_Swing);
  }

  void applyCharacterHitBoxAirbornStrikeDown(GameFight2DCharacter character){
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      const rangeX = 75.0;
      const rangeY = 180.0;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (yDiff > 0) continue;
      if (yDiff < -rangeY) continue;
      otherCharacter.hurtAirborn();
      otherCharacter.damage += 5;
      if (otherCharacter.grounded) {
        otherCharacter.accelerationY -= 20;
      } else {
        otherCharacter.accelerationY += 20;
      }
      emitEventPunch(character);
    }
  }

  void applyCharacterHitBoxAirbornStrikeUp(GameFight2DCharacter character){
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      const rangeX = 75.0;
      const rangeY = 180.0;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (yDiff < 0) continue;
      if (yDiff > rangeY) continue;
      otherCharacter.hurtAirborn();
      otherCharacter.accelerationY -= 40;
      otherCharacter.damage += 5;
      emitEventPunch(character);
    }
  }

  void applyCharacterHitBoxAirbornStrike(GameFight2DCharacter character){
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;
    var emitPunch = false;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      const rangeX = 75.0;
      const rangeY = 75.0;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (rangeY < yDiff.abs()) continue;
      otherCharacter.hurtAirborn();
      otherCharacter.damage += 5;
      otherCharacter.accelerationY -= 20;
      otherCharacter.accelerationX += character.facingLeft ? -10 : 10;
      emitPunch = true;
    }
    if (emitPunch){
      emitEventPunch(character);
    }
  }

  void applyCharacterSceneCollision(GameFight2DCharacter character) {
       var tileType = scene.getTileTypeAtXY(character.x, character.y + 50.0);
       if (tileType == GameFight2DNodeType.Grass) {
         if (!character.grounded) {
           onGrounded(character);

           if (character.velocityY > 2){
             emitEvent(character: character, event: GameFight2DEvents.Footstep);
           }
         }
         while (scene.getTileTypeAtXY(character.x, character.y + 49.0) == GameFight2DNodeType.Grass){
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


