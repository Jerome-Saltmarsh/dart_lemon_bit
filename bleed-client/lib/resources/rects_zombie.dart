import 'dart:ui';

import '../common.dart';
import '../keys.dart';
import 'rects_utils.dart';

const int zombieFramWidth = 36;
const int zombieFrameHeight = 35;

final _Rects rects = _Rects();

class _Rects {
  final _ZombieRects zombie = _ZombieRects();
}

class _ZombieRects {
  final _ZombieRectsIdle idle = _ZombieRectsIdle();
  final _ZombieRectsWalking walking = _ZombieRectsWalking();
  final _ZombieRectsDead dead = _ZombieRectsDead();
  final _ZombieRectsStriking striking = _ZombieRectsStriking();
}

class _ZombieRectsIdle {
  final Rect downLeft = _frame(1);
  final Rect left = _frame(2);
  final Rect upLeft = _frame(3);
  final Rect up = _frame(4);
  final Rect upRight = _frame(1);
  final Rect right = _frame(2);
  final Rect downRight = _frame(3);
  final Rect down = _frame(4);
}

class _ZombieRectsDead {
  final Rect downLeft = _frame(29);
  final Rect left = _frame(30);
  final Rect upLeft = _frame(31);
  final Rect up = _frame(32);
  final Rect upRight = _frame(29);
  final Rect right = _frame(30);
  final Rect downRight = _frame(31);
  final Rect down = _frame(32);
}

class _ZombieRectsWalking {
  List<Rect> up = [
    _frame(14),
    _frame(15),
    _frame(16),
    _frame(15),
  ];

  List<Rect> upRight = [
    _frame(17),
    _frame(18),
    _frame(19),
    _frame(18),
  ];

  List<Rect> right = [
    _frame(20),
    _frame(21),
    _frame(22),
    _frame(21),
  ];

  List<Rect> downRight = [
    _frame(23),
    _frame(24),
    _frame(25),
    _frame(24),
  ];

  List<Rect> down = [
    _frame(26),
    _frame(27),
    _frame(28),
    _frame(27),
  ];

  List<Rect> downLeft = [
    _frame(5),
    _frame(6),
    _frame(7),
    _frame(6),
  ];

  List<Rect> left = [
    _frame(8),
    _frame(9),
    _frame(10),
    _frame(9),
  ];

  List<Rect> upLeft = [
    _frame(11),
    _frame(12),
    _frame(13),
    _frame(12),
  ];
}

class _ZombieRectsStriking {
  List<Rect> up = [
    _frame(4),
    _frame(36),
    _frame(4),
  ];

  List<Rect> upRight = [
    _frame(1),
    _frame(37),
    _frame(1),
  ];

  List<Rect> right = [
    _frame(2),
    _frame(38),
    _frame(2),
  ];

  List<Rect> downRight = [
    _frame(3),
    _frame(39),
    _frame(3),
  ];

  List<Rect> down = [
    _frame(4),
    _frame(40),
    _frame(4),
  ];

  List<Rect> downLeft = [
    _frame(1),
    _frame(33),
    _frame(1),
  ];

  List<Rect> left = [
    _frame(2),
    _frame(34),
    _frame(2),
  ];

  List<Rect> upLeft = [
    _frame(3),
    _frame(35),
    _frame(3),
  ];
}


Rect _frame(int index) {
  return Rect.fromLTWH(((index - 1) * zombieFramWidth).toDouble(), 0.0,
      zombieFramWidth.toDouble(), zombieFrameHeight.toDouble());
}

Rect mapZombieSpriteRect(dynamic character) {
  switch (character[stateIndex]) {
    case characterStateIdle:
      return getZombieIdleRect(character);
    case characterStateWalking:
      return getZombieWalkingRect(character);
    case characterStateDead:
      return getZombieDeadRect(character);
    case characterStateStriking:
      return getZombieStrikingRect(character);
  }
  throw Exception("Could not get character sprite rect");
}

Rect getZombieIdleRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rects.zombie.idle.up;
    case directionUpRight:
      return rects.zombie.idle.upRight;
    case directionRight:
      return rects.zombie.idle.right;
    case directionDownRight:
      return rects.zombie.idle.downRight;
    case directionDown:
      return rects.zombie.idle.down;
    case directionDownLeft:
      return rects.zombie.idle.downLeft;
    case directionLeft:
      return rects.zombie.idle.left;
    case directionUpLeft:
      return rects.zombie.idle.upLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getZombieWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(rects.zombie.walking.up, character);
    case directionUpRight:
      return getFrameLoop(rects.zombie.walking.upRight, character);
    case directionRight:
      return getFrameLoop(rects.zombie.walking.right, character);
    case directionDownRight:
      return getFrameLoop(rects.zombie.walking.downRight, character);
    case directionDown:
      return getFrameLoop(rects.zombie.walking.down, character);
    case directionDownLeft:
      return getFrameLoop(rects.zombie.walking.downLeft, character);
    case directionLeft:
      return getFrameLoop(rects.zombie.walking.left, character);
    case directionUpLeft:
      return getFrameLoop(rects.zombie.walking.upLeft, character);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getZombieDeadRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rects.zombie.dead.up;
    case directionUpRight:
      return rects.zombie.dead.upRight;
    case directionRight:
      return rects.zombie.dead.right;
    case directionDownRight:
      return rects.zombie.dead.downRight;
    case directionDown:
      return rects.zombie.dead.down;
    case directionDownLeft:
      return rects.zombie.dead.left;
    case directionLeft:
      return rects.zombie.dead.left;
    case directionUpLeft:
      return rects.zombie.dead.upLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect getZombieStrikingRect(character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(rects.zombie.striking.up, character);
    case directionUpRight:
      return getFrameLoop(rects.zombie.striking.upRight, character);
    case directionRight:
      return getFrameLoop(rects.zombie.striking.right, character);
    case directionDownRight:
      return getFrameLoop(rects.zombie.striking.downRight, character);
    case directionDown:
      return getFrameLoop(rects.zombie.striking.down, character);
    case directionDownLeft:
      return getFrameLoop(rects.zombie.striking.downLeft, character);
    case directionLeft:
      return getFrameLoop(rects.zombie.striking.left, character);
    case directionUpLeft:
      return getFrameLoop(rects.zombie.striking.upLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}