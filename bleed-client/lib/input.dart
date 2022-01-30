import 'package:bleed_client/cube/camera3d.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/randomItem.dart';

import '../send.dart';
import 'common/enums/Direction.dart';
import 'ui/logic/showTextBox.dart';

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
// final Map<LogicalKeyboardKey, Function> keyPressedHandlers = {
//   modules.game.state.keyMap.interact: modules.game.actions.sendRequestInteract,
//   // modules.game.state.keyMap.perform: modules.game.actions.performPrimaryAction,
//   modules.game.state.keyMap.speakLetsGo: sayLetsGo,
//   modules.game.state.keyMap.speakLetsGreeting: sayGreeting,
//   modules.game.state.keyMap.waitASecond: sayWaitASecond,
//   modules.game.state.keyMap.text: toggleMessageBox,
//   modules.game.state.keyMap.hourForwards: skipHour,
//   modules.game.state.keyMap.hourBackwards: reverseHour,
//   // modules.game.state.keyMap.teleport: teleportToMouse,
//   modules.game.state.keyMap.casteFireball: sendRequestCastFireball,
//   key.digit1: (){
//     if (game.player.isHuman){
//       sendRequestEquip(1);
//     }else{
//       selectAbility1();
//     }
//   },
//   key.digit2: (){
//     if (game.player.isHuman){
//       sendRequestEquip(2);
//     }else{
//       selectAbility2();
//     }
//   },
//   modules.game.state.keyMap.equip3: (){
//     if (game.player.isHuman){
//       sendRequestEquip(3);
//     }else{
//       selectAbility3();
//     }
//   },
//   modules.game.state.keyMap.equip4: (){
//     if (game.player.isHuman){
//       sendRequestEquip(4);
//     }else{
//       selectAbility4();
//     }
//   },
//   modules.game.state.keyMap.equip5: (){
//     if (game.player.isHuman){
//        // sendRequestEquip(index)
//     }
//   },
//   modules.game.state.keyMap.equip1B: selectAbility1,
//   modules.game.state.keyMap.equip2B: selectAbility2,
//   modules.game.state.keyMap.equip3B: (){
//     if (game.player.isHuman){
//
//     }else{
//       selectAbility3();
//     }
//   },
//   modules.game.state.keyMap.equip4B: selectAbility4,
//   modules.game.state.keyMap.cubeFace0: (){
//     // storage.
//     camera3D.target.x = storage.get('target.x');
//     camera3D.target.y = storage.get('target.y');
//     camera3D.target.z = storage.get('target.z');
//     camera3D.position.x = storage.get('position.x');
//     camera3D.position.y = storage.get('position.y');
//     camera3D.position.z = storage.get('position.z');
//   },
//   modules.game.state.keyMap.cubeFaceI: (){
//     storage.put('target.x', camera3D.target.x);
//     storage.put('target.y', camera3D.target.y);
//     storage.put('target.z', camera3D.target.z);
//     storage.put('position.x', camera3D.position.x);
//     storage.put('position.y', camera3D.position.y);
//     storage.put('position.z', camera3D.position.z);
//   },
//   key.arrowDown: (){
//   },
//   key.arrowRight: sendRequest.hourIncrease,
//   key.arrowLeft: sendRequest.hourDecrease,
//   key.u: (){
//     engine.state.camera.x = 0;
//     engine.state.camera.y = 0;
//     engine.state.zoom = 1;
//   },
// };



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
  modules.game.state.keyMap.interact: modules.game.actions.sendRequestInteract,
  key.arrowUp: sendRequest.spawnZombie,
};

Map<LogicalKeyboardKey, Function> _keyReleasedHandlers = {
  // keys.melee: stopMelee,
};

void onMouseScroll(double amount) {
  engine.state.targetZoom -= amount * game.settings.zoomSpeed;
}

void stopRunLeft() {
  modules.game.actions.setCharacterActionRun();
  setCharacterDirection(Direction.Left);
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
    if (modules.game.map.keyPressedHandlers.containsKey(key)) {
      modules.game.map.keyPressedHandlers[key]?.call();
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
  if (modules.game.map.keyPressedHandlers.containsKey(key)) {
    modules.game.map.keyPressedHandlers[key]?.call();
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


void setCharacterDirection(Direction value){
  modules.game.state.characterController.direction = value;
}

