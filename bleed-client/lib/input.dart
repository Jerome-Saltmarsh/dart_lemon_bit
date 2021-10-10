import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_input.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../common.dart';
import '../keys.dart';
import '../send.dart';
import '../settings.dart';
import 'maths.dart';
import 'state.dart';
import 'utils.dart';

LogicalKeyboardKey _keyReload = LogicalKeyboardKey.keyR;

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);

bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);

bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);

bool get keyEquipSniperRifle => keyPressed(LogicalKeyboardKey.digit3);

bool get keyEquipMachineGun => keyPressed(LogicalKeyboardKey.digit4);

bool get keyAimPressed => keyPressedSpace;

bool get keySprintPressed => inputRequest.sprint;

bool get keyPressedReload => keyPressed(_keyReload);

bool get keyPressedUseMedKit => keyPressed(LogicalKeyboardKey.keyH);

bool get keyPressedMenu => keyPressed(LogicalKeyboardKey.escape);

bool get keyPressedThrowGrenade => keyPressed(LogicalKeyboardKey.keyG);

bool get keyPressedShowStore => keyPressed(LogicalKeyboardKey.keyI);

bool get keyPressedPan => keyPressed(LogicalKeyboardKey.keyE);

bool get keyPressedMelee => keyPressed(LogicalKeyboardKey.keyF);

bool _throwingGrenade = false;
bool panningCamera = false;

Offset _mouseWorldStart;

_InputRequest inputRequest = _InputRequest();

void initInput() {
  RawKeyboard.instance.addListener(_handleKeyboardEvent);
}

void _handleKeyboardEvent(RawKeyEvent event) {
  if (editMode) return;

  if (event is RawKeyUpEvent) {
    _handleKeyUpEvent(event);
  } else if (event is RawKeyDownEvent) {
    _handleKeyDownEvent(event);
  }
  rebuildUIKeys();
}

final _Keys keys = _Keys();

class _Keys {
  LogicalKeyboardKey interact = LogicalKeyboardKey.keyE;
  LogicalKeyboardKey sprint = LogicalKeyboardKey.keyX;
  LogicalKeyboardKey runUp = LogicalKeyboardKey.keyW;
  LogicalKeyboardKey runRight = LogicalKeyboardKey.keyD;
  LogicalKeyboardKey runDown = LogicalKeyboardKey.keyS;
  LogicalKeyboardKey runLeft = LogicalKeyboardKey.keyA;
}

Map<LogicalKeyboardKey, bool> _keyDownState = {};

// triggered the first frame a key is down
Map<LogicalKeyboardKey, Function> _keyPressedHandlers = {
  keys.interact: sendRequestInteract,
  keys.runLeft: runLeft,
  keys.runUp: runUp,
  keys.runRight: runRight,
  keys.runDown: runDown,
};

// triggered after a key is held longer than one frame
Map<LogicalKeyboardKey, Function> _keyHeldHandlers = {
  keys.interact: sendRequestInteract,
  keys.runLeft: runLeft,
  keys.runUp: runUp,
  keys.runRight: runRight,
  keys.runDown: runDown,
};

Map<LogicalKeyboardKey, Function> _keyReleasedHandlers = {
  keys.runLeft: stopRunLeft,
  keys.runUp: stopRunUp,
  keys.runRight: stopRunRight,
  keys.runDown: stopRunDown,
};

void runLeft() {
  inputRequest.moveLeft = true;
}

void runUp() {
  inputRequest.moveUp = true;
}

void runRight() {
  inputRequest.moveRight = true;
}

void runDown() {
  inputRequest.moveDown = true;
}

void stopRunLeft() {
  inputRequest.moveLeft = false;
}

void stopRunUp() {
  inputRequest.moveUp = false;
}

void stopRunRight() {
  inputRequest.moveRight = false;
}

void stopRunDown() {
  inputRequest.moveDown = false;
}

void _handleKeyDownEvent(RawKeyDownEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (!_keyDownState.containsKey(key)) {
    // on key pressed
    _keyDownState[key] = true;
    if (_keyPressedHandlers.containsKey(key)) {
      _keyPressedHandlers[key].call();
    }
    return;
  }

  if (_keyDownState[key]) {
    // on key held
    if (_keyHeldHandlers.containsKey(key)) {
      _keyHeldHandlers[key].call();
    }
    return;
  }

  // on key pressed
  _keyDownState[key] = true;
  _keyPressedHandlers[key].call();
}

void _handleKeyUpEvent(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (_keyReleasedHandlers.containsKey(key)) {
    _keyReleasedHandlers[key].call();
  }
  // if (key == LogicalKeyboardKey.keyA) {
  //   inputRequest.moveLeft = false;
  //   return;
  // }
  //
  // if (key == LogicalKeyboardKey.keyD) {
  //   inputRequest.moveRight = false;
  //   return;
  // }
  //
  // if (key == LogicalKeyboardKey.keyW) {
  //   inputRequest.moveUp = false;
  //   return;
  // }
  //
  // if (key == LogicalKeyboardKey.keyS) {
  //   inputRequest.moveDown = false;
  //   return;
  // }
}

class _InputRequest {
  bool sprint = false;
  bool moveUp = false;
  bool moveRight = false;
  bool moveDown = false;
  bool moveLeft = false;
}

void readPlayerInput() {
  if (!playerAssigned) return;

  // if (keyPressedSpawnZombie) {
  //   sendRequestSpawnNpc();
  //   return;
  // }

  if (keyPressedThrowGrenade) {
    if (!_throwingGrenade && mouseAvailable) {
      _throwingGrenade = true;
      double mouseDistance = distance(
          compiledGame.playerX, compiledGame.playerY, mouseWorldX, mouseWorldY);
      double maxRange = 400;
      double throwDistance = min(mouseDistance, maxRange);
      double strength = throwDistance / maxRange;
      requestThrowGrenade(strength);
    }
  } else if (_throwingGrenade) {
    _throwingGrenade = false;
  }
  if (mouseAvailable) {
    requestAim = getMouseRotation();
  }

  if (keyPressedPan && !panningCamera) {
    panningCamera = true;
    _mouseWorldStart = mouseWorld;
  }

  if (panningCamera && !keyPressedPan) {
    panningCamera = false;
  }

  if (panningCamera) {
    Offset mouseWorldDiff = _mouseWorldStart - mouseWorld;
    cameraY += mouseWorldDiff.dy * zoom;
    cameraX += mouseWorldDiff.dx * zoom;
  }

  if (keyPressedMelee && mouseAvailable) {
    requestCharacterState = characterStateStriking;
    requestDirection = convertAngleToDirection(requestAim);
    return;
  }

  if (mouseClicked || keyPressedSpace) {
    requestCharacterState = characterStateFiring;
  } else {
    if (keyPressed(LogicalKeyboardKey.keyQ) && mouseAvailable) {
      requestDirection = convertAngleToDirection(requestAim);
      if (keySprintPressed) {
        requestCharacterState = characterStateRunning;
      } else {
        requestCharacterState = characterStateWalking;
      }
      return;
    }

    requestDirection = getKeyDirection();
    if (requestDirection == directionNone) {
      requestCharacterState = characterStateIdle;
      if (mouseAvailable) {
        double mouseWorldX = mouseX + cameraX;
        double mouseWorldY = mouseY + cameraY;
        for (dynamic npc in compiledGame.zombies) {
          if (diffOver(npc[x], mouseWorldX, playerAutoAimDistance)) continue;
          if (diffOver(npc[y], mouseWorldY, playerAutoAimDistance)) continue;
          requestCharacterState = characterStateAiming;
          requestDirection = convertAngleToDirection(requestAim);
          break;
        }
      }
    } else {
      if (keySprintPressed) {
        requestCharacterState = characterStateRunning;
      } else {
        requestCharacterState = characterStateWalking;
      }
    }
  }
  if (keyEquipHandGun) sendRequestEquipHandgun();
  if (keyEquipShotgun) sendRequestEquipShotgun();
  if (keyEquipSniperRifle) sendRequestEquipSniperRifle();
  if (keyEquipMachineGun) sendRequestEquipMachineGun();
}

int getKeyDirection() {
  if (inputRequest.moveUp) {
    if (inputRequest.moveRight) {
      return directionUpRight;
    } else if (inputRequest.moveLeft) {
      return directionUpLeft;
    } else {
      return directionUp;
    }
  } else if (inputRequest.moveDown) {
    if (inputRequest.moveRight) {
      return directionDownRight;
    } else if (inputRequest.moveLeft) {
      return directionDownLeft;
    } else {
      return directionDown;
    }
  } else if (inputRequest.moveLeft) {
    return directionLeft;
  } else if (inputRequest.moveRight) {
    return directionRight;
  }
  return directionNone;
}

Block createBlock2(double x, double y, double width, double length) {
  double halfWidth = width * 0.5;
  double halfLength = length * 0.5;

  double aX = adj(piQuarter * 5, halfLength);
  double aY = opp(piQuarter * 5, halfLength);
  double bX = adj(piQuarter * 3, halfWidth);
  double bY = opp(piQuarter * 3, halfWidth);
  double cX = adj(piQuarter * 1, halfLength);
  double cY = opp(piQuarter * 1, halfLength);
  double dX = adj(piQuarter * 7, halfWidth);
  double dY = opp(piQuarter * 7, halfWidth);

  double topX = x + cX + dX;
  double topY = y + cY + dY;
  double rightX = x + cX + bX;
  double rightY = y + cY + bY;
  double bottomX = x + bX + aX;
  double bottomY = y + bY + aY;
  double leftX = x + dX + aX;
  double leftY = y + dY + aY;

  Block block =
      createBlock(topX, topY, rightX, rightY, bottomX, bottomY, leftX, leftY);

  blockHouses.add(block);
  return block;
}
