import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/state/game.dart';
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
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/randomItem.dart';

import '../send.dart';
import 'common/enums/Direction.dart';
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
  LogicalKeyboardKey toggleLantern = LogicalKeyboardKey.keyL;
  LogicalKeyboardKey hourForwards = LogicalKeyboardKey.arrowRight;
  LogicalKeyboardKey hourBackwards = LogicalKeyboardKey.arrowLeft;
  LogicalKeyboardKey teleport = LogicalKeyboardKey.keyG;
  LogicalKeyboardKey casteFireball = LogicalKeyboardKey.keyZ;
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
  keys.teleport: teleportToMouse,
  keys.casteFireball: sendRequestCastFireball,
};

void teleportToMouse(){
  if (!mouseAvailable) return;
  sendRequestTeleport(mouseWorldX, mouseWorldY);
}

void toggleLantern(){
  lantern = !lantern;
}

void _onKeyPressedEnter(){
  hud.state.textBoxVisible.value ? sendAndCloseTextBox() : showTextBox();
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
  inputRequest.requestCharacterState = CharacterState.Striking;
  inputRequest.requestDirection = convertAngleToDirection(requestAim);
}

void stopMelee() {
  if (inputRequest.requestCharacterState != CharacterState.Striking) return;
  inputRequest.requestCharacterState = CharacterState.Idle;
}

void _handleKeyDownEvent(RawKeyDownEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible.value) {
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


// on text box visible should disable the character keyboard and vicer vercer

void _handleKeyUpEvent(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible.value) return;

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
  Direction requestDirection = Direction.None;
  CharacterState requestCharacterState = CharacterState.Idle;
}

void readPlayerInput() {
  // TODO This should be reactive
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

    inputRequest.requestCharacterState = CharacterState.Firing;
  } else {
    if (inputRequest.requestCharacterState == CharacterState.Striking) {
      return;
    }

    inputRequest.requestDirection = getKeyDirection();
    if (inputRequest.requestDirection == Direction.None) {
      inputRequest.requestCharacterState = CharacterState.Idle;
      return;
    }

    if (inputRequest.sprint) {
      inputRequest.requestCharacterState = CharacterState.Running;
      return;
    }

    inputRequest.requestCharacterState = CharacterState.Walking;
  }
}

Direction getKeyDirection() {
  if (inputRequest.moveUp) {
    if (inputRequest.moveRight) {
      return Direction.UpRight;
    } else if (inputRequest.moveLeft) {
      return Direction.UpLeft;
    } else {
      return Direction.Up;
    }
  } else if (inputRequest.moveDown) {
    if (inputRequest.moveRight) {
      return Direction.DownRight;
    } else if (inputRequest.moveLeft) {
      return Direction.DownLeft;
    } else {
      return Direction.Down;
    }
  } else if (inputRequest.moveLeft) {
    return Direction.Left;
  } else if (inputRequest.moveRight) {
    return Direction.Right;
  }
  return Direction.None;
}

