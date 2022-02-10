
import 'dart:ui';

import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  Offset _mouseWorldStart = Offset(0, 0);

  void update() {
    if (!webSocket.connected) return;
    if (state.player.uuid.value.isEmpty) return;

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
    if (state.status.value == GameStatus.Finished) return;
    readPlayerInput();
    isometric.update.call();
    if (!state.panningCamera && modules.game.state.player.alive.value) {
      cameraFollowPlayer();
    }

    sendRequestUpdatePlayer();
  }

  void cameraFollowPlayer() {
    engine.actions.cameraFollow(modules.game.state.player.x, modules.game.state.player.y, engine.state.cameraFollowSpeed);
  }

  void readPlayerInput() {
    // TODO This should be reactive
    if (!playerAssigned) return;

    if (hud.textBoxFocused) return;

    if (keyPressed(LogicalKeyboardKey.keyE) && !state.panningCamera) {
      state.panningCamera = true;
      _mouseWorldStart = mouseWorld;
    }

    if (state.panningCamera && !keyPressed(LogicalKeyboardKey.keyE)) {
      state.panningCamera = false;
    }

    if (state.panningCamera) {
      Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
      engine.state.camera.y += mouseWorldDiff.dy * engine.state.zoom;
      engine.state.camera.x += mouseWorldDiff.dx * engine.state.zoom;
    }
    final Direction? direction = getKeyDirection();
    if (direction != null){
      modules.game.state.characterController.direction = direction;
      modules.game.actions.setCharacterActionRun();
    }
  }

  Direction? getKeyDirection() {
    if (keyPressed(state.keyMap.runUp)) {
      if (keyPressed(state.keyMap.runRight)) {
        return Direction.UpRight;
      } else if (keyPressed(state.keyMap.runLeft)) {
        return Direction.UpLeft;
      } else {
        return Direction.Up;
      }
    } else if (keyPressed(state.keyMap.runDown)) {
      if (keyPressed(state.keyMap.runRight)) {
        return Direction.DownRight;
      } else if (keyPressed(state.keyMap.runLeft)) {
        return Direction.DownLeft;
      } else {
        return Direction.Down;
      }
    } else if (keyPressed(state.keyMap.runLeft)) {
      return Direction.Left;
    } else if (keyPressed(state.keyMap.runRight)) {
      return Direction.Right;
    }
    return null;
  }
}
