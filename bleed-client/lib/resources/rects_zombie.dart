import 'dart:ui';
import 'package:bleed_client/resources/rects_utils.dart';
import '../common.dart';
import '../keys.dart';

// interface
Rect mapZombieToRect(dynamic character) {
  switch (character[stateIndex]) {
    case characterStateIdle:
      return _mapIdle(character);
    case characterStateWalking:
      return _mapWalking(character);
    case characterStateDead:
      return _mapDead(character);
    case characterStateStriking:
      return _mapStriking(character);
  }
  throw Exception("Could not get character sprite rect");
}

// abstraction
const int _frameWidth = 36;
const int _frameHeight = 35;
final _Idle _idle = _Idle();
final _Walking _walking = _Walking();
final _Dead _dead = _Dead();
final _Striking _striking = _Striking();

Rect _mapIdle(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _idle.up;
    case directionUpRight:
      return _idle.upRight;
    case directionRight:
      return _idle.right;
    case directionDownRight:
      return _idle.downRight;
    case directionDown:
      return _idle.down;
    case directionDownLeft:
      return _idle.downLeft;
    case directionLeft:
      return _idle.left;
    case directionUpLeft:
      return _idle.upLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapWalking(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_walking.up, character);
    case directionUpRight:
      return getFrameLoop(_walking.upRight, character);
    case directionRight:
      return getFrameLoop(_walking.right, character);
    case directionDownRight:
      return getFrameLoop(_walking.downRight, character);
    case directionDown:
      return getFrameLoop(_walking.down, character);
    case directionDownLeft:
      return getFrameLoop(_walking.downLeft, character);
    case directionLeft:
      return getFrameLoop(_walking.left, character);
    case directionUpLeft:
      return getFrameLoop(_walking.upLeft, character);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapDead(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _dead.up;
    case directionUpRight:
      return _dead.upRight;
    case directionRight:
      return _dead.right;
    case directionDownRight:
      return _dead.downRight;
    case directionDown:
      return _dead.down;
    case directionDownLeft:
      return _dead.left;
    case directionLeft:
      return _dead.left;
    case directionUpLeft:
      return _dead.upLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect _mapStriking(character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_striking.up, character);
    case directionUpRight:
      return getFrameLoop(_striking.upRight, character);
    case directionRight:
      return getFrameLoop(_striking.right, character);
    case directionDownRight:
      return getFrameLoop(_striking.downRight, character);
    case directionDown:
      return getFrameLoop(_striking.down, character);
    case directionDownLeft:
      return getFrameLoop(_striking.downLeft, character);
    case directionLeft:
      return getFrameLoop(_striking.left, character);
    case directionUpLeft:
      return getFrameLoop(_striking.upLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}

class _Idle {
  final Rect downLeft = _frame(1);
  final Rect left = _frame(2);
  final Rect upLeft = _frame(3);
  final Rect up = _frame(4);
  final Rect upRight = _frame(1);
  final Rect right = _frame(2);
  final Rect downRight = _frame(3);
  final Rect down = _frame(4);
}

class _Dead {
  final Rect downLeft = _frame(29);
  final Rect left = _frame(30);
  final Rect upLeft = _frame(31);
  final Rect up = _frame(32);
  final Rect upRight = _frame(29);
  final Rect right = _frame(30);
  final Rect downRight = _frame(31);
  final Rect down = _frame(32);
}

class _Walking {
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

class _Striking {
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
  return Rect.fromLTWH(((index - 1) * _frameWidth).toDouble(), 0.0,
      _frameWidth.toDouble(), _frameHeight.toDouble());
}
