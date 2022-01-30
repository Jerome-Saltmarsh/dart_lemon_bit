
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:flutter/services.dart';
import 'package:lemon_watch/watch.dart';

class CharacterController {
  Direction direction = Direction.Down;
  final Watch<CharacterAction> action = Watch(CharacterAction.Idle);
  AbilityType ability = AbilityType.None;
}

class KeyMap {
  LogicalKeyboardKey perform = LogicalKeyboardKey.space;
  LogicalKeyboardKey interact = LogicalKeyboardKey.keyA;
  LogicalKeyboardKey runUp = LogicalKeyboardKey.keyW;
  LogicalKeyboardKey runRight = LogicalKeyboardKey.keyD;
  LogicalKeyboardKey runDown = LogicalKeyboardKey.keyS;
  LogicalKeyboardKey runLeft = LogicalKeyboardKey.keyA;
  LogicalKeyboardKey throwGrenade = LogicalKeyboardKey.keyG;
  LogicalKeyboardKey equip1 = LogicalKeyboardKey.digit1;
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