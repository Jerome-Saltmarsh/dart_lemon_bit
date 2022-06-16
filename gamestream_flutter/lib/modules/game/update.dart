import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/update.dart';
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
    updateIsometric();
    readPlayerInput();
    sendRequestUpdatePlayer();
  }

  void readPlayerInput() {
    // if (hud.textBoxFocused) return;

    if (_mouseLeftDown.value) {
      _gameActions.setCharacterActionPerform();
      return;
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
        return Direction.North_East;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        return Direction.North_West;
      }
      return Direction.North;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        return Direction.South_East;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        return Direction.South_West;
      }
      return Direction.South;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      return Direction.West;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      return Direction.East;
    }
    return null;
  }
}
