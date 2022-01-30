
import 'dart:ui';

import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';

class GameUpdate {

  Offset _mouseWorldStart = Offset(0, 0);

  void update() {
    if (!webSocket.connected) return;
    if (game.player.uuid.value.isEmpty) return;

    switch(game.type.value){
      case GameType.None:
        break;
      case GameType.Custom:
        _updateBleed();
        break;
      case GameType.MMO:
        _updateBleed();
        break;
      case GameType.Moba:
        _updateBleed();
        break;
      case GameType.BATTLE_ROYAL:
        _updateBleed();
        break;
      case GameType.CUBE3D:
        sendRequestUpdateCube3D();
        break;
      default:
        throw Exception("No update for ${game.type.value}");
    }
  }

  void _updateBleed(){
    if (game.status.value == GameStatus.Finished) return;

    game.framesSinceEvent++;
    readPlayerInput();
    isometric.update.updateParticles();
    isometric.update.deadZombieBlood();
    if (!panningCamera && game.player.alive.value) {
      cameraFollowPlayer();
    }
    updateParticleEmitters();
    sendRequestUpdatePlayer();
  }

  void updateParticleEmitters() {
    for (ParticleEmitter emitter in game.particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = getAvailableParticle();
      particle.active = true;
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }
  }

  void cameraFollowPlayer() {
    engine.actions.cameraFollow(game.player.x, game.player.y, engine.state.cameraFollowSpeed);
  }

  void readPlayerInput() {
    // TODO This should be reactive
    if (!playerAssigned) return;

    if (hud.textBoxFocused) return;

    if (keyPressedPan && !panningCamera) {
      panningCamera = true;
      _mouseWorldStart = mouseWorld;
    }

    if (panningCamera && !keyPressedPan) {
      panningCamera = false;
    }

    if (panningCamera) {
      Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
      engine.state.camera.y += mouseWorldDiff.dy * engine.state.zoom;
      engine.state.camera.x += mouseWorldDiff.dx * engine.state.zoom;
    }
    final Direction? direction = getKeyDirection();
    if (direction != null){
      characterController.direction = direction;
      setCharacterActionRun();
    }
  }

  Direction? getKeyDirection() {
    if (keyPressed(keys.runUp)) {
      if (keyPressed(keys.runRight)) {
        return Direction.UpRight;
      } else if (keyPressed(keys.runLeft)) {
        return Direction.UpLeft;
      } else {
        return Direction.Up;
      }
    } else if (keyPressed(keys.runDown)) {
      if (keyPressed(keys.runRight)) {
        return Direction.DownRight;
      } else if (keyPressed(keys.runLeft)) {
        return Direction.DownLeft;
      } else {
        return Direction.Down;
      }
    } else if (keyPressed(keys.runLeft)) {
      return Direction.Left;
    } else if (keyPressed(keys.runRight)) {
      return Direction.Right;
    }
    return null;
  }
}
