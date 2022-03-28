

import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/enums/Direction.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/ui/state/hud.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

final _player = modules.game.state.player;
final _controller = modules.game.state.characterController;

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {

    switch(game.type.value){
      case GameType.None:
        break;
      default:
        _updateBleed();
        break;
    }
  }

  void _updateBleed(){
    if (core.state.status.value == GameStatus.Finished) return;
    readPlayerInput();
    isometric.update.call();
    if (!state.panningCamera && _player.alive.value) {
      cameraFollowPlayer();
    }

    state.framesSinceOrbAcquired++;
    final mousePosition = engine.mousePosition;
    modules.hud.menuVisible.value =
        mousePosition.y < 200
            &&
        mousePosition.x > engine.screen.width - 300
    ;

    sendRequestUpdatePlayer();
  }

  void cameraFollowPlayer() {
    engine.cameraFollow(_player.x, _player.y, engine.cameraFollowSpeed);
  }

  void readPlayerInput() {
    if (hud.textBoxFocused) return;

    // if (keysPressed.contains(LogicalKeyboardKey.keyE) && !state.panningCamera) {
    //   state.panningCamera = true;
    // }

    // if (state.panningCamera && !keyPressed(LogicalKeyboardKey.keyE)) {
    //   state.panningCamera = false;
    // }

    // if (state.panningCamera) {
      // Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
      // engine.state.camera.y += mouseWorldDiff.dy * engine.state.zoom;
      // engine.state.camera.x += mouseWorldDiff.dx * engine.state.zoom;
    // }
    final direction = getKeyDirection();
    if (direction != null){
      _controller.angle = direction.index.toDouble();
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
      }
      if (keysPressed.contains(keyMap.runLeft)) {
        return Direction.UpLeft;
      }
      return Direction.Up;
    }

    if (keysPressed.contains(keyMap.runDown)) {
      if (keysPressed.contains(keyMap.runRight)) {
        return Direction.DownRight;
      }
      if (keysPressed.contains(keyMap.runLeft)) {
        return Direction.DownLeft;
      }
      return Direction.Down;
    }

    if (keysPressed.contains(keyMap.runLeft)) {
      return Direction.Left;
    }
    if (keysPressed.contains(keyMap.runRight)) {
      return Direction.Right;
    }
    return null;
  }
}
