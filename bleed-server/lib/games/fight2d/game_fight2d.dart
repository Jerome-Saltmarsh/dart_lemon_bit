import 'package:bleed_server/common/src/fight2d/game_fight2d_events.dart';
import 'package:bleed_server/common/src/fight2d/game_fight2d_node_type.dart';
import 'package:bleed_server/common/src/fight2d/game_fight2d_response.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/input_type.dart';
import 'package:bleed_server/common/src/maths.dart';
import 'package:bleed_server/core/game.dart';
import 'package:lemon_math/src.dart';

import 'game_fight2d_bot.dart';
import 'game_fight2d_character.dart';
import 'game_fight2d_player.dart';
import 'game_fight2d_scene.dart';

class GameFight2D extends Game<GameFight2DPlayer> {
  static const Minimum_Damage_Force_Hurt_Airborn = 15.0;
  static const Boundary_Y = 1000;
  static const Max_Players = 4;

  final characters = <GameFight2DCharacter>[];
  final GameFight2DScene scene;

  final bot = GameFight2DBot();

  GameFight2D({required this.scene}) : super(gameType: GameType.Fight2D) {
    characters.add(bot
      ..x = 500
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

    if (players.length == 2) {
      characters.remove(bot);
    }

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

    if (players.length == 2 && !characters.contains(bot)) {
      characters.add(bot);
    }

    for (final character in characters) {
      if (character is! GameFight2DBot) continue;
      if (character.target != player) continue;
      character.target = null;
    }
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
  }) {
    final xInt = character.x.toInt();
    final yInt = character.y.toInt();
    for (final player in players) {
      player.writeEvent(event: event, x: xInt, y: yInt);
    }
  }

  void updateCharacters() {
    for (final character in characters) {
      updateCharacter(character);
      if (character is GameFight2DBot) {
        updateGameFight2DBot(character);
      }
    }
  }

  void updateGameFight2DBot(GameFight2DBot bot) {
    if (bot.busy) return;

    if (bot.aiPause > 0){
      bot.aiPause--;
      bot.state = GameFight2DCharacterState.Idle;
      bot.target = null;
      return;
    }

    bot.aiPauseNext--;
    if (bot.aiPauseNext <= 0){
      bot.aiPause = randomInt(50, 200);
      bot.aiPauseNext = randomInt(50, 200);
    }

    var nearestCharacterDistanceSquared = 500.0 * 500.0;
    if (bot.target == null) {
       for (final character in characters) {
         if (character == bot) continue;
         final distanceSquared = getDistanceV2Squared(character.x, character.y, bot.x, bot.y);
         if (distanceSquared > nearestCharacterDistanceSquared) continue;
         nearestCharacterDistanceSquared = distanceSquared;
         bot.target = character;
         break;
       }
    }

    final target = bot.target;
    if (target == null) {
      bot.state = GameFight2DCharacterState.Idle;
      return;
    }

    if (bot.x < target.x){
      bot.faceRight();
      bot.state = GameFight2DCharacterState.Running;
    } else {
      bot.faceLeft();
      bot.state = GameFight2DCharacterState.Running;
    }

    final distanceX = (bot.x - target.x).abs();
    final distanceY = (bot.y - target.y).abs();

    if (distanceX < GameFight2DCharacter.Strike_Range_X){
      if (distanceY < GameFight2DCharacter.Strike_Range_Y){
          bot.state = GameFight2DCharacterState.Striking;
          bot.aiPause = randomInt(30, 100);
          return;
      }
    }
  }

  void updateCharacter(GameFight2DCharacter character) {
    if (character.y > Boundary_Y) {
      emitEvent(character: character, event: GameFight2DEvents.Death);
      character.respawn();
      character.x = randomBetween(50, scene.widthLength - 50);
    }

    character.update();
    applyCharacterSceneCollision(character);
    character.applyVelocity();
    emitEventJump(character);

    if (character.running && character.stateDuration % 6 == 0) {
      emitEvent(character: character, event: GameFight2DEvents.Footstep);
    }

    switch (character.state) {
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

  void applyCharacterHitBoxStrike(GameFight2DCharacter character) {
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;

    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      final xDiff = character.x - otherCharacter.x;
      if (GameFight2DCharacter.Strike_Range_X < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (GameFight2DCharacter.Strike_Range_Y < yDiff.abs()) continue;
      if (character.facingLeft) {
        if (xDiff > 0 && xDiff < GameFight2DCharacter.Strike_Range_X) {
          applyHit(src: character, target: otherCharacter);
        }
        return;
      }
      if (xDiff > 0) continue;
      if (xDiff < GameFight2DCharacter.Strike_Range_X) {
        applyHit(src: character, target: otherCharacter);
      }
    }
  }

  void applyCharacterHitBoxStrikeUp(GameFight2DCharacter character) {
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != 5) return;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      const rangeX = 75.0;
      const rangeY = 75.0;
      final xDiff = character.x - otherCharacter.x;
      if (rangeX < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (rangeY < yDiff.abs()) continue;
      applyHit(src: character, target: otherCharacter);
    }
  }

  void emitCharacterStrikeSwing(GameFight2DCharacter character) {
    if (character.stateDuration != character.strikeSwingFrame) return;
    emitEvent(character: character, event: GameFight2DEvents.Strike_Swing);
  }

  void applyCharacterHitBoxAirbornStrikeDown(GameFight2DCharacter character) {
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
      applyHit(src: character, target: otherCharacter);
    }
  }

  void applyCharacterHitBoxAirbornStrikeUp(GameFight2DCharacter character) {
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
      applyHit(src: character, target: otherCharacter);
    }
  }

  void applyCharacterHitBoxAirbornStrike(GameFight2DCharacter character) {
    emitCharacterStrikeSwing(character);
    if (character.stateDuration != character.strikeFrame) return;
    for (final otherCharacter in characters) {
      if (otherCharacter == character) continue;
      final xDiff = character.x - otherCharacter.x;
      if (GameFight2DCharacter.Strike_Range_X < xDiff.abs()) continue;
      final yDiff = character.y - otherCharacter.y;
      if (GameFight2DCharacter.Strike_Range_Y < yDiff.abs()) continue;
      applyHit(src: character, target: otherCharacter);
    }
  }

  void applyHit({
    required GameFight2DCharacter src,
    required GameFight2DCharacter target,
  }) {
    if (target.invulnerable) return;

    var damage = src.stateDamage;
    if (target.state == GameFight2DCharacterState.Crouching) {
      damage = damage ~/ 2;
    }
    if (damage == 0) return;
    final totalDamageForce = damage * target.damageForce;
    target.accelerationX += src.stateAttackForceX * totalDamageForce;
    final accelerationY = src.stateAttackForceY * totalDamageForce;

    if (target.grounded) {
      target.accelerationY -= accelerationY.abs();
    } else {
      target.accelerationY += accelerationY;
    }

    if (totalDamageForce > Minimum_Damage_Force_Hurt_Airborn) {
      target.hurtAirborn();
    } else {
      target.hurt();
    }
    if (src.facingLeft) {
      target.forceFaceRight();
    } else {
      target.forceFaceLeft();
    }

    target.damage += damage;
    emitEventPunch(src);
  }

  void applyCharacterSceneCollision(GameFight2DCharacter character) {
    if (character.velocityY < 0) {
      character.ignoreCollisions = true;
      character.grounded = false;
      return;
    }

    var tileType = scene.getTileTypeAtXY(character.x, character.y + 50.0);

    if (tileType == GameFight2DNodeType.Empty) {
      character.grounded = false;
      character.ignoreCollisions = false;
      return;
    }

    if (character.ignoreCollisions) return;

    if (!character.grounded) {
      onGrounded(character);

      if (character.velocityY > 2) {
        emitEvent(character: character, event: GameFight2DEvents.Footstep);
      }
    }
    while (scene.getTileTypeAtXY(character.x, character.y + 49.0) ==
        GameFight2DNodeType.Grass) {
      character.y--;
    }
    if (character.velocityY > 0) {
      character.velocityY = 0;
    }
  }

  /// EVENT HANDLER (DO NOT CALL)
  void onGrounded(GameFight2DCharacter character) {
    character.grounded = true;
    character.jumpCount = 0;
    character.forceIdle();
  }

  @override
  int get maxPlayers => 4;


}
