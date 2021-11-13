import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/render/functions/setAmbientLight.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/variables/lantern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/functions/key_pressed.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/randomItem.dart';

import '../common.dart';
import '../send.dart';
import '../settings.dart';
import 'maths.dart';
import 'state.dart';
import 'ui/logic/showTextBox.dart';
import 'utils.dart';

LogicalKeyboardKey _keyReload = LogicalKeyboardKey.keyR;

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);

bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);

bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);

bool get keyEquipSniperRifle => keyPressed(LogicalKeyboardKey.digit3);

bool get keyEquipMachineGun => keyPressed(LogicalKeyboardKey.digit4);

bool get keyPressedSpace => keyPressed(LogicalKeyboardKey.space);

bool get keySprintPressed => inputRequest.sprint;

bool get keyPressedReload => keyPressed(_keyReload);

bool get keyPressedUseMedKit => keyPressed(LogicalKeyboardKey.keyH);

bool get keyPressedMenu => keyPressed(LogicalKeyboardKey.escape);

bool get keyPressedThrowGrenade => keyPressed(LogicalKeyboardKey.keyG);

bool get keyPressedShowStore => keyPressed(LogicalKeyboardKey.keyI);

bool get keyPressedPan => keyPressed(LogicalKeyboardKey.keyE);

bool get keyPressedMelee => keyPressed(LogicalKeyboardKey.keyF);

bool panningCamera = false;

Offset _mouseWorldStart;

_InputRequest inputRequest = _InputRequest();

void registerPlayKeyboardHandler() {
  RawKeyboard.instance.addListener(_handleKeyboardEvent);
}

void deregisterPlayKeyboardHandler(){
  print("deregisterPlayKeyboardHandler()");
  RawKeyboard.instance.removeListener(_handleKeyboardEvent);
}

void _handleKeyboardEvent(RawKeyEvent event) {
  if (event is RawKeyUpEvent) {
    _handleKeyUpEvent(event);
  } else if (event is RawKeyDownEvent) {
    _handleKeyDownEvent(event);
  }
}

final _Keys keys = _Keys();

class _Keys {
  LogicalKeyboardKey interact = LogicalKeyboardKey.keyE;
  LogicalKeyboardKey sprint = LogicalKeyboardKey.keyQ;
  LogicalKeyboardKey sprint2 = LogicalKeyboardKey.keyC;
  LogicalKeyboardKey runUp = LogicalKeyboardKey.keyW;
  LogicalKeyboardKey runRight = LogicalKeyboardKey.keyD;
  LogicalKeyboardKey runDown = LogicalKeyboardKey.keyS;
  LogicalKeyboardKey runLeft = LogicalKeyboardKey.keyA;
  LogicalKeyboardKey throwGrenade = LogicalKeyboardKey.keyG;
  LogicalKeyboardKey melee = LogicalKeyboardKey.keyF;
  LogicalKeyboardKey equipHandgun = LogicalKeyboardKey.digit1;
  LogicalKeyboardKey equipShotgun = LogicalKeyboardKey.digit2;
  LogicalKeyboardKey equipSniperRifle = LogicalKeyboardKey.digit3;
  LogicalKeyboardKey equipAssaultRifle = LogicalKeyboardKey.digit4;
  LogicalKeyboardKey speakLetsGo = LogicalKeyboardKey.digit9;
  LogicalKeyboardKey speakLetsGreeting = LogicalKeyboardKey.digit8;
  LogicalKeyboardKey waitASecond = LogicalKeyboardKey.digit0;
  LogicalKeyboardKey text = LogicalKeyboardKey.enter;
  // LogicalKeyboardKey ambientBright = LogicalKeyboardKey.digit4;
  // LogicalKeyboardKey ambientMedium = LogicalKeyboardKey.digit5;
  // LogicalKeyboardKey ambientDark = LogicalKeyboardKey.digit6;
  // LogicalKeyboardKey ambientVeryDark = LogicalKeyboardKey.digit7;
  LogicalKeyboardKey toggleLantern = LogicalKeyboardKey.keyL;
  LogicalKeyboardKey hourForwards = LogicalKeyboardKey.arrowRight;
  LogicalKeyboardKey hourBackwards = LogicalKeyboardKey.arrowLeft;
}

Map<LogicalKeyboardKey, bool> _keyDownState = {};

final List<String> letsGo = [
  "Come on!",
  "Let's go!",
  'Follow me!',
];

final List<String> greetings = [
  'Hello',
  'Hi',
  'Greetings',
];

final List<String> waitASecond = [
  'Wait a second',
  'Just a moment'
];


// triggered the first frame a key is down
Map<LogicalKeyboardKey, Function> _keyPressedHandlers = {
  keys.interact: sendRequestInteract,
  keys.runLeft: runLeft,
  keys.runUp: runUp,
  keys.runRight: runRight,
  keys.runDown: runDown,
  keys.throwGrenade: throwGrenade,
  keys.melee: melee,
  keys.equipHandgun: sendRequestEquipHandgun,
  keys.equipShotgun: sendRequestEquipShotgun,
  keys.equipSniperRifle: sendRequestEquipSniperRifle,
  keys.equipAssaultRifle: sendRequestEquipAssaultRifle,
  keys.sprint: toggleSprint,
  keys.sprint2: toggleSprint,
  keys.speakLetsGo: sayLetsGo,
  keys.speakLetsGreeting: sayGreeting,
  keys.waitASecond: sayWaitASecond,
  keys.text: _onKeyPressedEnter,
  // keys.ambientBright: setAmbientLightBright,
  // keys.ambientMedium: setAmbientLightMedium,
  // keys.ambientDark: setAmbientLightDark,
  keys.toggleLantern: toggleLantern,
  // keys.ambientVeryDark: setAmbientLightVeryDark,
  keys.hourForwards: skipHour,
  keys.hourBackwards: reverseHour,
};

void toggleLantern(){
  lantern = !lantern;
}

void _onKeyPressedEnter(){
  print("_onKeyPressedEnter()");
  hud.state.textBoxVisible ? sendAndCloseTextBox() : showTextBox();
}

void sayGreeting(){
  speak(randomItem(greetings));
}

void sayLetsGo(){
  speak(randomItem(letsGo));
}

void sayWaitASecond(){
  speak(randomItem(waitASecond));
}


void toggleSprint() {
  inputRequest.sprint = !inputRequest.sprint;
}

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
  keys.melee: stopMelee,
};

void throwGrenade() {
  if (!mouseAvailable) return;
  double mouseDistance = distanceBetween(
      game.playerX, game.playerY, mouseWorldX, mouseWorldY);
  double maxRange = 400; // TODO refactor magic variable
  double throwDistance = min(mouseDistance, maxRange);
  double strength = throwDistance / maxRange;
  requestThrowGrenade(strength);
}

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

void melee() {
  requestCharacterState = characterStateStriking;
  requestDirection = convertAngleToDirection(requestAim);
}

void stopMelee() {
  if (requestCharacterState != characterStateStriking) return;
  requestCharacterState = characterStateIdle;
}

void _handleKeyDownEvent(RawKeyDownEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible) {
    if (key == keys.text){
      sendAndCloseTextBox();
    }
    return;
  }

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
  if (_keyPressedHandlers.containsKey(key)) {
    _keyPressedHandlers[key].call();
  }
}

void _handleKeyUpEvent(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible) return;

  if (_keyReleasedHandlers.containsKey(key)) {
    _keyReleasedHandlers[key].call();
  }

  _keyDownState[key] = false;
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
    camera.y += mouseWorldDiff.dy * zoom;
    camera.x += mouseWorldDiff.dx * zoom;
  }

  if (mouseClicked || keyPressedSpace) {
    double mX = mouseWorldX;
    double mY = mouseWorldY;
    for(int i = 0; i < game.totalNpcs; i++){
      Character interactableNpc = game.interactableNpcs[i];
      if (diffOver(interactableNpc.x, mX, settings.interactRadius)) continue;
      if (diffOver(interactableNpc.y, mY, settings.interactRadius)) continue;
      sendRequestInteract();
      return;
    }

    requestCharacterState = characterStateFiring;
  } else {
    if (requestCharacterState == characterStateStriking) {
      return;
    }

    requestDirection = getKeyDirection();
    if (requestDirection == directionNone) {
      requestCharacterState = characterStateIdle;
      if (mouseAvailable) {
        double mouseWorldX = mouseX + camera.x;
        double mouseWorldY = mouseY + camera.y;
        for (Zombie zombie in game.zombies) {
          if (diffOver(zombie.x, mouseWorldX, playerAutoAimDistance)) continue;
          if (diffOver(zombie.y, mouseWorldY, playerAutoAimDistance)) continue;
          requestCharacterState = characterStateAiming;
          requestDirection = convertAngleToDirection(requestAim);
          break;
        }
      }
      return;
    } else {
      if (inputRequest.sprint) {
        requestCharacterState = characterStateRunning;
      } else {
        requestCharacterState = characterStateWalking;
      }
    }
  }
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

  double aX = adjacent(piQuarter * 5, halfLength);
  double aY = opposite(piQuarter * 5, halfLength);
  double bX = adjacent(piQuarter * 3, halfWidth);
  double bY = opposite(piQuarter * 3, halfWidth);
  double cX = adjacent(piQuarter * 1, halfLength);
  double cY = opposite(piQuarter * 1, halfLength);
  double dX = adjacent(piQuarter * 7, halfWidth);
  double dY = opposite(piQuarter * 7, halfWidth);

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
