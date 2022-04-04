import 'package:gamestream_flutter/classes/Character.dart';
import 'package:lemon_watch/watch.dart';
import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/enums/Direction.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/state/hud.dart';
import 'package:lemon_engine/engine.dart';

import '../../state/game.dart';
import 'state.dart';

final _player = modules.game.state.player;
final _controller = modules.game.state.characterController;
final _status = core.state.status;
final _menuVisible = modules.hud.menuVisible;
final totalUpdates = Watch(0);

class GameUpdate {

  final GameState state;

  GameUpdate(this.state);

  void update() {
    // TODO remove this check
    totalUpdates.value++;
    if (_status.value == GameStatus.Finished) return;
    framesSinceUpdateReceived.value++;
    readPlayerInput();
    isometric.update.call();

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
    final gameActions = modules.game.actions;

    if (engine.mouseLeftDown.value){
      gameActions.setCharacterActionPerform();
      return;
    }

    if (direction != null){
      _controller.angle = direction;
      gameActions.setCharacterActionRun();
      return;
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
