import 'package:bleed_common/Direction.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'state.dart';

final _controller = modules.game.state.characterController;
final _gameActions = modules.game.actions;
final _mouseLeftDown = engine.mouseLeftDown;
final totalUpdates = Watch(0);

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
    totalUpdates.value++;
    framesSinceUpdateReceived.value++;
    readPlayerInput();
    isometric.updateParticles();
    sendRequestUpdatePlayer();
    updateProjectiles();
    updateFootstepAudio();
  }

  void updateFootstepAudio() {
    if (engine.frame % 2 == 0) return;

    for (var i = 0; i < game.totalPlayers.value; i++) {
        final player = game.players[i];
        if (player.running && player.frame % 2 == 0) {
          audio.footstepGrass(player.x, player.y);
        }
    }

    for (var i = 0; i < game.totalZombies.value; i++) {
      final zombie = game.zombies[i];
      if (zombie.running && zombie.frame % 2 == 0) {
        audio.footstepGrass(zombie.x, zombie.y);
      }
    }
  }

  void updateProjectiles() {
    // if (engine.frame % 5 != 0) return;
    for (var i = 0; i < game.totalProjectiles; i++) {
      final projectile = game.projectiles[i];
      if (projectile.type != ProjectileType.Orb) continue;
      spawnParticleOrbShard(x: projectile.x, y: projectile.y);
    }
  }

  void readPlayerInput() {
    // if (hud.textBoxFocused) return;

    if (modules.game.structureType.value == null){
      if (_mouseLeftDown.value) {
        _gameActions.setCharacterActionPerform();
        return;
      }
    }

    final direction = getKeyDirection();
    if (direction != null){
      _controller.angle = direction;
      _gameActions.setCharacterActionRun();
    }
  }

  int? getKeyDirection() {
    final keysPressed = keyboardInstance.keysPressed;

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        return Direction.UpRight;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        return Direction.UpLeft;
      }
      return Direction.Up;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        return Direction.DownRight;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        return Direction.DownLeft;
      }
      return Direction.Down;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.Left;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.Right;
    }
    return null;
  }
}
