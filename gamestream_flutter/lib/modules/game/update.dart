

import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/enums/Direction.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/state/hud.dart';
import 'package:lemon_engine/engine.dart';

import 'state.dart';

final _player = modules.game.state.player;
final _controller = modules.game.state.characterController;

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
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
    final gameActions = modules.game.actions;

    if (direction != null){
      _controller.angle = direction;
      gameActions.setCharacterActionRun();
      return;
    }
    if (engine.mouseLeftDown.value){
      gameActions.setCharacterActionPerform();
    }
  }

  int? getKeyDirection() {
    final keysPressed = keyboardInstance.keysPressed;
    final keyMap = state.keyMap;

    if (keysPressed.contains(keyMap.runUp)) {
      if (keysPressed.contains(keyMap.runRight)) {
        return directionUpRightIndex;
      }
      if (keysPressed.contains(keyMap.runLeft)) {
        return directionUpLeftIndex;
      }
      return directionUpIndex;
    }

    if (keysPressed.contains(keyMap.runDown)) {
      if (keysPressed.contains(keyMap.runRight)) {
        return directionDownRightIndex;
      }
      if (keysPressed.contains(keyMap.runLeft)) {
        return directionDownLeftIndex;
      }
      return directionDownIndex;
    }

    if (keysPressed.contains(keyMap.runLeft)) {
      return directionLeftIndex;
    }
    if (keysPressed.contains(keyMap.runRight)) {
      return directionRightIndex;
    }
    return null;
  }
}
