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

  Character? findPlayerCharacter(){
    final total = game.totalPlayers.value;
    for (var i = 0; i < total; i++) {
      final character = game.players[i];
      if (character.x != _player.x) continue;
      if (character.y != _player.y) continue;
      return character;
    }
    return null;
  }

  void applyFrameSmoothing() {
    if (!state.frameSmoothing.value) return;
    
    // final previousPlayerScreen = worldToScreenX(x)
    
    // if (framesSinceUpdateReceived.value != 1) return;
    // state.framesSmoothed.value++;
    // final total = game.totalPlayers.value;
    // for (var i = 0; i < total; i++) {
    //   final character = game.players[i];
    //   if (!character.running) continue;
    //   final angle = character.angle;
    //   const amount = 2.5;
    //   if (character.x == _player.x && character.y == _player.y) {
    //     // character.x += adjacent(angle, amount);
    //     // character.y += opposite(angle, amount);
    //     _player.x += _player.velocity.x * 0.5;
    //     _player.y += _player.velocity.y * 0.5;
    //     character.x = _player.x;
    //     character.y = _player.y;
    //   }
    // }
  }

  void update() {
    // TODO remove this check
    totalUpdates.value++;
    if (_status.value == GameStatus.Finished) return;
    applyFrameSmoothing();
    framesSinceUpdateReceived.value++;
    readPlayerInput();
    isometric.update.call();
    if (!state.panningCamera && _player.alive.value) {
      cameraFollowPlayer();
    }

    state.framesSinceOrbAcquired++;
    final mousePosition = engine.mousePosition;
    _menuVisible.value =
        mousePosition.y < 200
            &&
            mousePosition.x > engine.screen.width - 500
    ;

    sendRequestUpdatePlayer();
  }

  var previousPlayerScreenX = 0.0;
  var previousPlayerScreenY = 0.0;

  void cameraFollowPlayer() {
    const cameraFollowSpeed = 0.005;
    // engine.cameraFollow(_player.x, _player.y, cameraFollowSpeed);
    // if (!state.frameSmoothing.value) return;

    // engine.cameraCenter(_player.x, _player.y);

    // final currentPlayerScreenX = worldToScreenX(_player.x);
    // final currentPlayerScreenY = worldToScreenY(_player.y);
    // final diffPlayerScreenX = currentPlayerScreenX - previousPlayerScreenX;
    // final diffPlayerScreenY = currentPlayerScreenY - previousPlayerScreenY;
    // final adjustmentX = (diffPlayerScreenX * 0.5) / engine.zoom;
    // final adjustmentY = (diffPlayerScreenY * 0.5) / engine.zoom;
    // engine.camera.x += adjustmentX;
    // engine.camera.y += adjustmentY;
    // previousPlayerScreenX = worldToScreenX(_player.x);
    // previousPlayerScreenY = worldToScreenY(_player.y);
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
