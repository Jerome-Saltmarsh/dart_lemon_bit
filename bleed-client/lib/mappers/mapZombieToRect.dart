import 'dart:ui';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

// interface
Rect mapZombieToRect(Zombie zombie) {
  switch (zombie.state) {
    case CharacterState.Idle:
      return _mapIdle(zombie);
    case CharacterState.Walking:
      return _mapWalking(zombie);
    case CharacterState.Dead:
      return _mapDead(zombie);
    case CharacterState.Striking:
      return _mapStriking(zombie);
    default:
      throw Exception("Could not get zombie sprite rect");
  }
}

// abstraction
const int _frameWidth = 36;
const int _frameHeight = 35;
final _Idle _idle = _Idle();
final _Walking _walking = _Walking();
final _Dead _dead = _Dead();
final _Striking _striking = _Striking();

Rect _mapIdle(Zombie zombie) {
  switch (zombie.direction) {
    case Direction.Up:
      return _idle.up;
    case Direction.UpRight:
      return _idle.upRight;
    case Direction.Right:
      return _idle.right;
    case Direction.DownRight:
      return _idle.downRight;
    case Direction.Down:
      return _idle.down;
    case Direction.DownLeft:
      return _idle.downLeft;
    case Direction.Left:
      return _idle.left;
    case Direction.UpLeft:
      return _idle.upLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapWalking(Zombie zombie) {
  switch (zombie.direction) {
    case Direction.Up:
      return _loopFrame(_walking.up, zombie);
    case Direction.UpRight:
      return _loopFrame(_walking.upRight, zombie);
    case Direction.Right:
      return _loopFrame(_walking.right, zombie);
    case Direction.DownRight:
      return _loopFrame(_walking.downRight, zombie);
    case Direction.Down:
      return _loopFrame(_walking.down, zombie);
    case Direction.DownLeft:
      return _loopFrame(_walking.downLeft, zombie);
    case Direction.Left:
      return _loopFrame(_walking.left, zombie);
    case Direction.UpLeft:
      return _loopFrame(_walking.upLeft, zombie);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapDead(Zombie zombie) {
  switch (zombie.direction) {
    case Direction.Up:
      return _dead.up;
    case Direction.UpRight:
      return _dead.upRight;
    case Direction.Right:
      return _dead.right;
    case Direction.DownRight:
      return _dead.downRight;
    case Direction.Down:
      return _dead.down;
    case Direction.DownLeft:
      return _dead.left;
    case Direction.Left:
      return _dead.left;
    case Direction.UpLeft:
      return _dead.upLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect _mapStriking(Zombie zombie) {
  switch (zombie.direction) {
    case Direction.Up:
      return _loopFrame(_striking.up, zombie);
    case Direction.UpRight:
      return _loopFrame(_striking.upRight, zombie);
    case Direction.Right:
      return _loopFrame(_striking.right, zombie);
    case Direction.DownRight:
      return _loopFrame(_striking.downRight, zombie);
    case Direction.Down:
      return _loopFrame(_striking.down, zombie);
    case Direction.DownLeft:
      return _loopFrame(_striking.downLeft, zombie);
    case Direction.Left:
      return _loopFrame(_striking.left, zombie);
    case Direction.UpLeft:
      return _loopFrame(_striking.upLeft, zombie);
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
  ];

  List<Rect> upRight = [
    _frame(1),
    _frame(37),
  ];

  List<Rect> right = [
    _frame(2),
    _frame(38),
  ];

  List<Rect> downRight = [
    _frame(3),
    _frame(39),
  ];

  List<Rect> down = [
    _frame(4),
    _frame(40),
  ];

  List<Rect> downLeft = [
    _frame(1),
    _frame(33),
  ];

  List<Rect> left = [
    _frame(2),
    _frame(34),
  ];

  List<Rect> upLeft = [
    _frame(3),
    _frame(35),
  ];
}

Rect _loopFrame(List<Rect> frames, Zombie zombie) {
  int actualFrame = zombie.frame ~/ 5;
  return frames[actualFrame % frames.length]; // TODO Calling frames.length is expensive
}

Rect _frame(int index) {
  return Rect.fromLTWH(((index - 1) * _frameWidth).toDouble(), 0.0,
      _frameWidth.toDouble(), _frameHeight.toDouble());
}
