
import 'package:bleed_common/AbilityType.dart';
import 'package:bleed_common/CharacterAction.dart';
import 'package:flutter/services.dart';
import 'package:lemon_watch/watch.dart';


class CharacterController {
  final action = Watch(CharacterAction.Idle);
  var ability = AbilityType.None;
  var angle = 0;
}

class KeyMap {
  final perform = LogicalKeyboardKey.space;
  final interact = LogicalKeyboardKey.keyA;
  final runUp = LogicalKeyboardKey.keyW;
  final runRight = LogicalKeyboardKey.keyD;
  final runDown = LogicalKeyboardKey.keyS;
  final runLeft = LogicalKeyboardKey.keyA;
  final throwGrenade = LogicalKeyboardKey.keyG;
  final equip1 = LogicalKeyboardKey.digit1;
  final equip2 = LogicalKeyboardKey.digit2;
  final equip3 = LogicalKeyboardKey.digit3;
  final equip4 = LogicalKeyboardKey.digit4;
  final equip5 = LogicalKeyboardKey.digit5;
  final equip6 = LogicalKeyboardKey.digit6;
  final debug = LogicalKeyboardKey.keyZ;
  final equip1B = LogicalKeyboardKey.keyQ;
  final equip2B = LogicalKeyboardKey.keyE;
  final equip3B = LogicalKeyboardKey.keyF;
  final equip4B = LogicalKeyboardKey.keyC;
  final speakLetsGo = LogicalKeyboardKey.digit9;
  final speakLetsGreeting = LogicalKeyboardKey.digit8;
  final waitASecond = LogicalKeyboardKey.digit0;
  final speak = LogicalKeyboardKey.enter;
  final toggleLantern = LogicalKeyboardKey.keyL;
  final toggleAudio = LogicalKeyboardKey.keyM;
  final hourForwards = LogicalKeyboardKey.arrowRight;
  final hourBackwards = LogicalKeyboardKey.arrowLeft;
  final toggleObjectsDestroyable = LogicalKeyboardKey.keyP;
  final teleport = LogicalKeyboardKey.keyG;
  final spawnZombie = LogicalKeyboardKey.arrowUp;
  final respawn = LogicalKeyboardKey.keyN;
  final casteFireball = LogicalKeyboardKey.keyZ;
  final cubeFace0 = LogicalKeyboardKey.keyO;
  final cubeFaceI = LogicalKeyboardKey.keyI;
}