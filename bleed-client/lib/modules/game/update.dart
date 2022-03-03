

import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  // Vector2 _mouseWorldStart = Offset(0, 0);

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
    if (core.state.status.value == GameStatus.Finished) return;
    readPlayerInput();
    isometric.update.call();
    if (!state.panningCamera && modules.game.state.player.alive.value) {
      cameraFollowPlayer();
    }

    state.framesSinceOrbAcquired++;

    // for (final character in game.humans) {
    //    if(!character.state.running) continue;
    //    if (character.frame % 4 != 0) continue;
    //    audio.footstep(character.x, character.y);
    // }

    sendRequestUpdatePlayer();
  }

  void cameraFollowPlayer() {
    engine.cameraFollow(modules.game.state.player.x, modules.game.state.player.y, engine.cameraFollowSpeed);
  }

  void readPlayerInput() {
    // TODO This should be reactive
    if (!playerAssigned) return;

    if (hud.textBoxFocused) return;

    // if (keysPressed.contains(LogicalKeyboardKey.keyE) && !state.panningCamera) {
    //   state.panningCamera = true;
    // }

    // if (state.panningCamera && !keyPressed(LogicalKeyboardKey.keyE)) {
    //   state.panningCamera = false;
    // }

    if (state.panningCamera) {
      // Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
      // engine.state.camera.y += mouseWorldDiff.dy * engine.state.zoom;
      // engine.state.camera.x += mouseWorldDiff.dx * engine.state.zoom;
    }
    final direction = getKeyDirection();
    if (direction != null){
      modules.game.state.characterController.angle = convertDirectionToAngle(direction);
      modules.game.actions.setCharacterActionRun();
      return;
    }

    if (engine.mouseLeftDown.value){
      modules.game.actions.setCharacterActionPerform();
    }
  }

  Direction? getKeyDirection() {
    final keysPressed = keyboardInstance.keysPressed;
    final keyMap = state.keyMap;

    if (keysPressed.contains(keyMap.runUp)) {
      if (keysPressed.contains(keyMap.runRight)) {
        return Direction.UpRight;
      } else if (keysPressed.contains(keyMap.runLeft)) {
        return Direction.UpLeft;
      } else {
        return Direction.Up;
      }
    } else if (keysPressed.contains(keyMap.runDown)) {
      if (keysPressed.contains(keyMap.runRight)) {
        return Direction.DownRight;
      } else if (keysPressed.contains(keyMap.runLeft)) {
        return Direction.DownLeft;
      } else {
        return Direction.Down;
      }
    } else if (keysPressed.contains(keyMap.runLeft)) {
      return Direction.Left;
    } else if (keysPressed.contains(keyMap.runRight)) {
      return Direction.Right;
    }
    return null;
  }
}
