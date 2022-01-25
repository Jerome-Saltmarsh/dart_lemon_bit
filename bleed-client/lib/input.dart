import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/cube/camera3d.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/variables/lantern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/functions/key_pressed.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_math/randomItem.dart';
import 'package:lemon_watch/watch.dart';

import '../send.dart';
import 'common/enums/Direction.dart';
import 'ui/logic/showTextBox.dart';
import 'utils.dart';

bool get keyPressedPan => keyPressed(LogicalKeyboardKey.keyE);

bool panningCamera = false;

Offset _mouseWorldStart = Offset(0, 0);

final _CharacterController characterController = _CharacterController();
final RawKeyboard rawKeyboard = RawKeyboard.instance;

void performPrimaryAction() {
  setCharacterAction(CharacterAction.Perform);
}

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

final _Key key = _Key();

class _Key {
  final LogicalKeyboardKey arrowUp = LogicalKeyboardKey.arrowUp;
  final LogicalKeyboardKey arrowDown = LogicalKeyboardKey.arrowDown;
  final LogicalKeyboardKey arrowLeft = LogicalKeyboardKey.arrowLeft;
  final LogicalKeyboardKey arrowRight = LogicalKeyboardKey.arrowRight;
  final LogicalKeyboardKey space = LogicalKeyboardKey.space;
  final LogicalKeyboardKey a = LogicalKeyboardKey.keyA;
  final LogicalKeyboardKey b = LogicalKeyboardKey.keyB;
  final LogicalKeyboardKey c = LogicalKeyboardKey.keyC;
  final LogicalKeyboardKey d = LogicalKeyboardKey.keyD;
  final LogicalKeyboardKey e = LogicalKeyboardKey.keyE;
  final LogicalKeyboardKey f = LogicalKeyboardKey.keyF;
  final LogicalKeyboardKey g = LogicalKeyboardKey.keyG;
  final LogicalKeyboardKey h = LogicalKeyboardKey.keyH;
  final LogicalKeyboardKey i = LogicalKeyboardKey.keyI;
  final LogicalKeyboardKey j = LogicalKeyboardKey.keyJ;
  final LogicalKeyboardKey k = LogicalKeyboardKey.keyK;
  final LogicalKeyboardKey l = LogicalKeyboardKey.keyL;
  final LogicalKeyboardKey m = LogicalKeyboardKey.keyM;
  final LogicalKeyboardKey n = LogicalKeyboardKey.keyN;
  final LogicalKeyboardKey o = LogicalKeyboardKey.keyO;
  final LogicalKeyboardKey p = LogicalKeyboardKey.keyP;
  final LogicalKeyboardKey q = LogicalKeyboardKey.keyQ;
  final LogicalKeyboardKey r = LogicalKeyboardKey.keyR;
  final LogicalKeyboardKey s = LogicalKeyboardKey.keyS;
  final LogicalKeyboardKey t = LogicalKeyboardKey.keyT;
  final LogicalKeyboardKey u = LogicalKeyboardKey.keyU;
  final LogicalKeyboardKey v = LogicalKeyboardKey.keyV;
  final LogicalKeyboardKey w = LogicalKeyboardKey.keyW;
  final LogicalKeyboardKey x = LogicalKeyboardKey.keyX;
  final LogicalKeyboardKey y = LogicalKeyboardKey.keyY;
  final LogicalKeyboardKey z = LogicalKeyboardKey.keyZ;
  final LogicalKeyboardKey digit0 = LogicalKeyboardKey.digit0;
  final LogicalKeyboardKey digit1 = LogicalKeyboardKey.digit1;
  final LogicalKeyboardKey digit2 = LogicalKeyboardKey.digit2;
  final LogicalKeyboardKey digit3 = LogicalKeyboardKey.digit3;
  final LogicalKeyboardKey digit4 = LogicalKeyboardKey.digit4;
  final LogicalKeyboardKey digit5 = LogicalKeyboardKey.digit5;
}

class _Keys {
  LogicalKeyboardKey perform = key.space;
  LogicalKeyboardKey interact = key.e;
  LogicalKeyboardKey runUp = key.w;
  LogicalKeyboardKey runRight = key.d;
  LogicalKeyboardKey runDown = key.s;
  LogicalKeyboardKey runLeft = key.a;
  LogicalKeyboardKey throwGrenade = key.g;
  LogicalKeyboardKey equip1 = key.digit1;
  LogicalKeyboardKey equip2 = LogicalKeyboardKey.digit2;
  LogicalKeyboardKey equip3 = LogicalKeyboardKey.digit3;
  LogicalKeyboardKey equip4 = LogicalKeyboardKey.digit4;
  LogicalKeyboardKey equip5 = LogicalKeyboardKey.digit5;
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
  LogicalKeyboardKey cubeFace0 = LogicalKeyboardKey.keyO;
  LogicalKeyboardKey cubeFaceI = LogicalKeyboardKey.keyI;
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
  keys.speakLetsGo: sayLetsGo,
  keys.speakLetsGreeting: sayGreeting,
  keys.waitASecond: sayWaitASecond,
  keys.text: toggleMessageBox,
  keys.toggleLantern: toggleLantern,
  keys.hourForwards: skipHour,
  keys.hourBackwards: reverseHour,
  keys.teleport: teleportToMouse,
  keys.casteFireball: sendRequestCastFireball,
  key.digit1: (){
    if (game.player.isHuman){
      sendRequestEquip(1);
    }else{
      selectAbility1();
    }
  },
  key.digit2: (){
    if (game.player.isHuman){
      sendRequestEquip(2);
    }else{
      selectAbility2();
    }
  },
  keys.equip3: (){
    if (game.player.isHuman){
      sendRequestEquip(3);
    }else{
      selectAbility3();
    }
  },
  keys.equip4: (){
    if (game.player.isHuman){
      sendRequestEquip(4);
    }else{
      selectAbility4();
    }
  },
  keys.equip5: (){
    if (game.player.isHuman){
       // sendRequestEquip(index)
    }
  },
  keys.equip1B: selectAbility1,
  keys.equip2B: selectAbility2,
  keys.equip3B: (){
    if (game.player.isHuman){
      melee();
    }else{
      selectAbility3();
    }
  },
  keys.equip4B: selectAbility4,
  keys.cubeFace0: (){
    // storage.
    camera3D.target.x = storage.get('target.x');
    camera3D.target.y = storage.get('target.y');
    camera3D.target.z = storage.get('target.z');
    camera3D.position.x = storage.get('position.x');
    camera3D.position.y = storage.get('position.y');
    camera3D.position.z = storage.get('position.z');
  },
  keys.cubeFaceI: (){
    storage.put('target.x', camera3D.target.x);
    storage.put('target.y', camera3D.target.y);
    storage.put('target.z', camera3D.target.z);
    storage.put('position.x', camera3D.position.x);
    storage.put('position.y', camera3D.position.y);
    storage.put('position.z', camera3D.position.z);
  },
  key.arrowDown: (){
  },
  key.arrowRight: sendRequest.hourIncrease,
  key.arrowLeft: sendRequest.hourDecrease,
  key.u: (){
    engine.state.camera.x = 0;
    engine.state.camera.y = 0;
    engine.state.zoom = 1;
  },
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
  key.arrowUp: sendRequest.spawnZombie,
};

Map<LogicalKeyboardKey, Function> _keyReleasedHandlers = {
  // keys.melee: stopMelee,
};

void onMouseScroll(double amount) {
  targetZoom -= amount * game.settings.zoomSpeed;
}

void stopRunLeft() {
  setCharacterActionRun();
  setCharacterDirection(Direction.Left);
}

void melee() {
  // characterController.action.value = CharacterAction.
  // characterController.direction = convertAngleToDirection(characterController.requestAim);
  // sendRequestMe
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
      _keyPressedHandlers[key]?.call();
    }
    return;
  }

  if (_keyDownState[key]!) {
    // on key held
    if (_keyHeldHandlers.containsKey(key)) {
      _keyHeldHandlers[key]?.call();
    }
    return;
  }

  // on key pressed
  _keyDownState[key] = true;
  if (_keyPressedHandlers.containsKey(key)) {
    _keyPressedHandlers[key]?.call();
  }
}

// on text box visible should disable the character keyboard and vicer vercer

void _handleKeyUpEventPlayMode(RawKeyUpEvent event) {
  LogicalKeyboardKey key = event.logicalKey;

  if (hud.state.textBoxVisible.value) return;

  if (_keyReleasedHandlers.containsKey(key)) {
    _keyReleasedHandlers[key]?.call();
  }

  _keyDownState[key] = false;
}

class _CharacterController {
  Direction direction = Direction.Down;
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
    engine.state.camera.y += mouseWorldDiff.dy * engine.state.zoom;
    engine.state.camera.x += mouseWorldDiff.dx * engine.state.zoom;
  }
  final Direction? direction = getKeyDirection();
  if (direction != null){
    characterController.direction = direction;
    setCharacterActionRun();
  }
}

Direction? getKeyDirection() {
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
  return null;
}
