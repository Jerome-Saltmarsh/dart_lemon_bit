import 'dart:ui';

import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/variables/lantern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/functions/key_pressed.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/randomItem.dart';
import 'package:lemon_watch/watch.dart';

import '../send.dart';
import 'common/enums/Direction.dart';
import 'ui/logic/showTextBox.dart';
import 'utils.dart';

LogicalKeyboardKey _keyReload = LogicalKeyboardKey.keyR;

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);

bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);

bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);

bool get keyEquipSniperRifle => keyPressed(LogicalKeyboardKey.digit3);

bool get keyEquipMachineGun => keyPressed(LogicalKeyboardKey.digit4);

bool get keyPressedSpace => keyPressed(LogicalKeyboardKey.space);

bool get keyPressedReload => keyPressed(_keyReload);

bool get keyPressedUseMedKit => keyPressed(LogicalKeyboardKey.keyH);

bool get keyPressedMenu => keyPressed(LogicalKeyboardKey.escape);

bool get keyPressedThrowGrenade => keyPressed(LogicalKeyboardKey.keyG);

bool get keyPressedShowStore => keyPressed(LogicalKeyboardKey.keyI);

bool get keyPressedPan => keyPressed(LogicalKeyboardKey.keyE);

bool get keyPressedMelee => keyPressed(LogicalKeyboardKey.keyF);

bool panningCamera = false;

Offset _mouseWorldStart;

final _CharacterController characterController = _CharacterController();

void performPrimaryAction() {
  setCharacterAction(CharacterAction.Perform);
}

final RawKeyboard rawKeyboard = RawKeyboard.instance;

void registerPlayKeyboardHandler() {
  print("registerPlayKeyboardHandler()");
  registerKeyboardHandler(_keyboardEventHandlerPlayMode);
}


void registerTextBoxKeyboardHandler(){
  registerKeyboardHandler(_handleKeyboardEventTextBox);
}

void deregisterTextBoxKeyboardHandler(){
  deregisterKeyboardHandler(_handleKeyboardEventTextBox);
}

void deregisterPlayKeyboardHandler() {
  print("deregisterPlayKeyboardHandler()");
  deregisterKeyboardHandler(_keyboardEventHandlerPlayMode);
}

void registerKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.addListener(handler);
}

void deregisterKeyboardHandler(Function(RawKeyEvent event) handler) {
  rawKeyboard.removeListener(handler);
}

void _keyboardEventHandlerPlayMode(RawKeyEvent event) {
  if (event is RawKeyUpEvent) {
    _handleKeyUpEventPlayMode(event);
  } else if (event is RawKeyDownEvent) {
    _handleKeyDownEventPlayMode(event);
  }
}

void _handleKeyboardEventTextBox(RawKeyEvent event) {
  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      sendAndCloseTextBox();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      hideTextBox();
    }
  }
}

final _Keys keys = _Keys();

class _Keys {
  LogicalKeyboardKey perform = LogicalKeyboardKey.space;
  LogicalKeyboardKey interact = LogicalKeyboardKey.keyE;
  LogicalKeyboardKey runUp = LogicalKeyboardKey.keyW;
  LogicalKeyboardKey runRight = LogicalKeyboardKey.keyD;
  LogicalKeyboardKey runDown = LogicalKeyboardKey.keyS;
  LogicalKeyboardKey runLeft = LogicalKeyboardKey.keyA;
  LogicalKeyboardKey throwGrenade = LogicalKeyboardKey.keyG;
  LogicalKeyboardKey melee = LogicalKeyboardKey.keyF;
  LogicalKeyboardKey equip1 = LogicalKeyboardKey.digit1;
  LogicalKeyboardKey equip2 = LogicalKeyboardKey.digit2;
  LogicalKeyboardKey equip3 = LogicalKeyboardKey.digit3;
  LogicalKeyboardKey equip4 = LogicalKeyboardKey.digit4;
  LogicalKeyboardKey equip1B = LogicalKeyboardKey.keyQ;
  LogicalKeyboardKey equip2B = LogicalKeyboardKey.keyE;
  LogicalKeyboardKey equip3B = LogicalKeyboardKey.keyF;
  LogicalKeyboardKey equip4B = LogicalKeyboardKey.keyC;
  LogicalKeyboardKey speakLetsGo = LogicalKeyboardKey.digit9;
  LogicalKeyboardKey speakLetsGreeting = LogicalKeyboardKey.digit8;
  LogicalKeyboardKey waitASecond = LogicalKeyboardKey.digit0;
  LogicalKeyboardKey text = LogicalKeyboardKey.enter;
  LogicalKeyboardKey toggleLantern = LogicalKeyboardKey.keyL;
  LogicalKeyboardKey hourForwards = LogicalKeyboardKey.arrowRight;
  LogicalKeyboardKey hourBackwards = LogicalKeyboardKey.arrowLeft;
  LogicalKeyboardKey teleport = LogicalKeyboardKey.keyG;
  LogicalKeyboardKey casteFireball = LogicalKeyboardKey.keyZ;
  LogicalKeyboardKey arrowUp = LogicalKeyboardKey.arrowUp;
  LogicalKeyboardKey arrowDown = LogicalKeyboardKey.arrowDown;
  LogicalKeyboardKey pixelExplosion = LogicalKeyboardKey.keyP;
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

final List<String> waitASecond = ['Wait a second', 'Just a moment'];

// triggered the first frame a key is down
Map<LogicalKeyboardKey, Function> _keyPressedHandlers = {
  keys.interact: sendRequestInteract,
  keys.perform: performPrimaryAction,
  keys.melee: melee,
  keys.speakLetsGo: sayLetsGo,
  keys.speakLetsGreeting: sayGreeting,
  keys.waitASecond: sayWaitASecond,
  keys.text: toggleMessageBox,
  keys.toggleLantern: toggleLantern,
  keys.hourForwards: skipHour,
  keys.hourBackwards: reverseHour,
  keys.teleport: teleportToMouse,
  keys.casteFireball: sendRequestCastFireball,
  keys.equip1: selectAbility1,
  keys.equip2: selectAbility2,
  keys.equip3: selectAbility3,
  keys.equip4: selectAbility4,
  keys.equip1B: selectAbility1,
  keys.equip2B: selectAbility2,
  keys.equip3B: selectAbility3,
  keys.equip4B: selectAbility4,
};

void selectAbility1() {
  sendRequestSelectAbility(1);
}

void selectAbility2() {
  sendRequestSelectAbility(2);
}

void selectAbility3() {
  sendRequestSelectAbility(3);
}

void selectAbility4() {
  sendRequestSelectAbility(4);
}

void teleportToMouse() {
  if (!mouseAvailable) return;
  sendRequestTeleport(mouseWorldX, mouseWorldY);
}

void toggleLantern() {
  lantern = lanternModes[(lantern.index + 1) % lanternModes.length];
}

void toggleMessageBox() {
  hud.state.textBoxVisible.value ? sendAndCloseTextBox() : showTextBox();
}

void sayGreeting() {
  speak(randomItem(greetings));
}

void sayLetsGo() {
  speak(randomItem(letsGo));
}

void sayWaitASecond() {
  speak(randomItem(waitASecond));
}

// triggered after a key is held longer than one frame
Map<LogicalKeyboardKey, Function> _keyHeldHandlers = {
  keys.interact: sendRequestInteract,
  // keys.runLeft: runLeft,
  // keys.runUp: runUp,
  // keys.runRight: runRight,
  // keys.runDown: runDown,
};

Map<LogicalKeyboardKey, Function> _keyReleasedHandlers = {
  keys.melee: stopMelee,
};

void onMouseScroll(double amount) {
  Offset center1 = screenCenterWorld;
  targetZoom -= amount * game.settings.zoomSpeed;
  if (targetZoom < game.settings.maxZoom) targetZoom = game.settings.maxZoom;
  cameraCenter(center1.dx, center1.dy);
}

// void runLeft() {
//   setCharacterDirection(Direction.Left);
//   setCharacterActionRun();
// }
//
// void runUp() {
//   setCharacterDirection(Direction.Up);
//   setCharacterActionRun();
// }
//
// void runRight() {
//   setCharacterActionRun();
//   setCharacterDirection(Direction.Right);
// }
//
// void runDown() {
//   setCharacterActionRun();
//   setCharacterDirection(Direction.Down);
// }

void stopRunLeft() {
  setCharacterActionRun();
  setCharacterDirection(Direction.Left);
}

void melee() {
  // characterController.characterState = CharacterState.Striking;
  // characterController.direction = convertAngleToDirection(characterController.requestAim);
}

void stopMelee() {
  // if (characterController.characterState != CharacterState.Striking) return;
  // characterController.characterState = CharacterState.Idle;
}

void _handleKeyDownEventPlayMode(RawKeyDownEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (key == LogicalKeyboardKey.enter){
    if (hud.state.textBoxVisible.value){
      sendAndCloseTextBox();
    }
  }

  if (!_keyDownState.containsKey(key)) {
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

void _handleKeyUpEventPlayMode(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible.value) return;

  if (_keyReleasedHandlers.containsKey(key)) {
    _keyReleasedHandlers[key].call();
  }

  _keyDownState[key] = false;
}

class _CharacterController {
  Direction direction = Direction.None;
  final Watch<CharacterAction> action = Watch(CharacterAction.Idle);
  AbilityType ability = AbilityType.None;
}

void setCharacterAction(CharacterAction value){
  if (value.index < characterController.action.value.index) return;
  characterController.action.value = value;
}

void setCharacterActionRun(){
  setCharacterAction(CharacterAction.Run);
}

void setCharacterDirection(Direction value){
  characterController.direction = value;
}

void readPlayerInput() {
  // TODO This should be reactive
  if (!playerAssigned) return;

  if (hud.textBoxFocused) return;

  // if (characterController.action.value == CharacterAction.Perform) return;

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

  characterController.direction = getKeyDirection();
  if (characterController.direction != Direction.None) {
    setCharacterActionRun();
  }
}

Direction getKeyDirection() {
  if (keyPressed(keys.runUp)) {
    if (keyPressed(keys.runRight)) {
      return Direction.UpRight;
    } else if (keyPressed(keys.runLeft)) {
      return Direction.UpLeft;
    } else {
      return Direction.Up;
    }
  } else if (keyPressed(keys.runDown)) {
    if (keyPressed(keys.runRight)) {
      return Direction.DownRight;
    } else if (keyPressed(keys.runLeft)) {
      return Direction.DownLeft;
    } else {
      return Direction.Down;
    }
  } else if (keyPressed(keys.runLeft)) {
    return Direction.Left;
  } else if (keyPressed(keys.runRight)) {
    return Direction.Right;
  }
  return Direction.None;
}
