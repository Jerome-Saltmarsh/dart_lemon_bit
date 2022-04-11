import 'package:bleed_common/Direction.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/state/hud.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';

import 'state.dart';

final _controller = modules.game.state.characterController;
final _menuVisible = modules.hud.menuVisible;
final _gameActions = modules.game.actions;
final _mouseLeftDown = engine.mouseLeftDown;
final totalUpdates = Watch(0);

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
    totalUpdates.value++;
    framesSinceUpdateReceived.value++;

    // if (framesSinceUpdateReceived.value >= 3){
    //   print("frames since update: ${framesSinceUpdateReceived.value}");
    // }

    readPlayerInput();
    isometric.updateParticles();


    state.framesSinceOrbAcquired++;
    final mousePosition = engine.mousePosition;
    _menuVisible.value =
        mousePosition.y < 200
            &&
            mousePosition.x > engine.screen.width - 500
    ;

    sendRequestUpdatePlayer();
  }

  void readPlayerInput() {
    if (hud.textBoxFocused) return;

    final direction = getKeyDirection();

    if (_mouseLeftDown.value){
      _gameActions.setCharacterActionPerform();
      return;
    }

    if (direction != null){
      _controller.angle = direction;
      _gameActions.setCharacterActionRun();
      return;
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
