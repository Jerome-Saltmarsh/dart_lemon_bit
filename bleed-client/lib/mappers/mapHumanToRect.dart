import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

import '../resources/rects_utils.dart';

// interface
Rect mapHumanToRect(Weapon weapon, CharacterState state, Direction direction, int frame) {
  switch (state) {
    case CharacterState.Idle:
      return _mapIdleRect(direction);
    case CharacterState.Walking:
      return _mapWalkingRect(direction, frame);
    case CharacterState.Dead:
      return _mapDeadRect(direction, frame);
    case CharacterState.Aiming:
      return _mapAimingRect(direction);
    case CharacterState.Firing:
      return _mapFiringRect(weapon, direction, frame);
    case CharacterState.Striking:
      return _mapStrikingRect(direction, frame);
    case CharacterState.Running:
      return _mapRunningRect(direction, frame);
    case CharacterState.Reloading:
      return _mapReloadingRect(direction, frame);
    case CharacterState.ChangingWeapon:
      return _mapReloadingRect(direction, frame);
  }
  throw Exception("Could not get character sprite rect");
}

// TODO state belongs in state directory
const int _humanSpriteFrameWidth = 36;
const int _humanSpriteFrameHeight = 35;
const double halfHumanSpriteFrameWidth = _humanSpriteFrameWidth * 0.5;
const double halfHumanSpriteFrameHeight = _humanSpriteFrameHeight * 0.5;
const int _frameRateRunning = 3;
final _RectsHuman _human = _RectsHuman();

class _RectsHuman {
  final _Idle idle = _Idle();
  final _Walking walking = _Walking();
  final _Running running = _Running();
  final _FiringShotgun firingShotgun = _FiringShotgun();
  final _Changing changing = _Changing();
  final _Dying dying = _Dying();
}

class _Idle {
  final Rect down = _frame(1);
  final Rect downRight = _frame(2);
  final Rect right = _frame(3);
  final Rect upRight = _frame(4);
  final Rect up = _frame(5);
  final Rect upLeft = _frame(6);
  final Rect left = _frame(7);
  final Rect downLeft = _frame(8);
}

class _Walking {
  final List<Rect> down = _frames([9, 10, 11 , 12]);
  final List<Rect> downRight = _frames([13, 14, 15, 16]);
  final List<Rect> right = _frames([17, 18, 19, 20]);
  final List<Rect> upRight = _frames([21, 22, 23, 24]);
  final List<Rect> up = _frames([25, 26, 27, 28]);
  final List<Rect> upLeft = _frames([29, 30, 31, 32]);
  final List<Rect> left = _frames([33, 34, 35, 36]);
  final List<Rect> downLeft = _frames([37, 38, 39, 40]);
}

class _Running {
  final List<Rect> down = _frames([1, 2, 3, 4]);
  final List<Rect> downRight = _frames([5, 6, 7, 8]);
  final List<Rect> right = _frames([9, 10, 11, 12]);
  final List<Rect> upRight = _frames([13, 14, 15, 16]);
  final List<Rect> up = _frames([17, 18, 19, 20]);
  final List<Rect> upLeft = _frames([21, 22, 23, 24]);
  final List<Rect> left = _frames([25, 26, 27, 28]);
  final List<Rect> downLeft = _frames([29, 30, 31, 32]);
}

class _FiringShotgun {
  final List<Rect> down = _frames([1]);
  final List<Rect> downRight = _frames([2]);
  final List<Rect> right = _frames([3]);
  final List<Rect> upRight = _frames([4]);
  final List<Rect> up = _frames([5]);
  final List<Rect> upLeft = _frames([6]);
  final List<Rect> left = _frames([7]);
  final List<Rect> downLeft  = _frames([8]);
}

class _Changing {
  final List<Rect> down = _frames([1, 2]);
  final List<Rect> downRight = _frames([3, 4]);
  final List<Rect> right = _frames([5, 6]);
  final List<Rect> upRight = _frames([7, 8]);
  final List<Rect> up = _frames([9, 10]);
  final List<Rect> upLeft = _frames([11, 12]);
  final List<Rect> left = _frames([13, 14]);
  final List<Rect> downLeft = _frames([15, 16]);
}

class _Dying {
  final List<Rect> down = _frames([1, 2]);
  final List<Rect> downRight = _frames([3, 4]);
  final List<Rect> right = _frames([5, 6]);
  final List<Rect> upRight = _frames([7, 8]);
  final List<Rect> up = _frames([9, 10]);
  final List<Rect> upLeft = _frames([11, 12]);
  final List<Rect> left = _frames([13, 14]);
  final List<Rect> downLeft = _frames([15, 16]);
}

Rect _aimingDownLeft = _frame(21);
Rect _aimingLeft = _frame(23);
Rect _aimingUpLeft = _frame(25);
Rect _aimingUp = _frame(27);
Rect _aimingUpRight = _frame(29);
Rect _aimingRight = _frame(31);
Rect _aimingDownRight = _frame(33);
Rect _aimingDown = _frame(35);

List<Rect> _strikingDownLeft = _frames([37, 38]);
List<Rect> _strikingLeft = _frames([39, 40]);
List<Rect> _strikingUpLeft = _frames([41, 42]);
List<Rect> _strikingUp = _frames([43, 44]);
List<Rect> _strikingUpRight = _frames([45, 46]);
List<Rect> _strikingRight = _frames([47, 48]);
List<Rect> _strikingDownRight = _frames([49, 50]);
List<Rect> _strikingDown = _frames([51, 52]);


List<Rect> _frames(List<int> indexes) {
  List<Rect> rects = [];
  for (int i in indexes) {
    rects.add(_frame(i));
  }
  return rects;
}

Rect _frame(int index) {
  return _getHumanSpriteRect(index - 1);
}

Rect _getHumanSpriteRect(int index) {
  return Rect.fromLTWH(index * 64.0, 0.0, 64, 64);
}

Rect _mapWalkingRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrameLoop(_human.walking.down, frame);
    case Direction.DownRight:
      return getFrameLoop(_human.walking.downRight, frame);
    case Direction.Right:
      return getFrameLoop(_human.walking.right, frame);
    case Direction.UpRight:
      return getFrameLoop(_human.walking.upRight, frame);
    case Direction.Up:
      return getFrameLoop(_human.walking.up, frame);
    case Direction.UpLeft:
      return getFrameLoop(_human.walking.upLeft, frame);
    case Direction.Left:
      return getFrameLoop(_human.walking.left, frame);
    case Direction.DownLeft:
      return getFrameLoop(_human.walking.downLeft, frame);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapReloadingRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrameLoop(_human.changing.down, frame);
    case Direction.DownRight:
      return getFrameLoop(_human.changing.downRight, frame);
    case Direction.Right:
      return getFrameLoop(_human.changing.right, frame);
    case Direction.UpRight:
      return getFrameLoop(_human.changing.upRight, frame);
    case Direction.Up:
      return getFrameLoop(_human.changing.up, frame);
    case Direction.UpLeft:
      return getFrameLoop(_human.changing.upLeft, frame);
    case Direction.Left:
      return getFrameLoop(_human.changing.left, frame);
    case Direction.DownLeft:
      return getFrameLoop(_human.changing.downLeft, frame);
  }
  throw Exception("Could not get character reloading sprite rect");
}

Rect _mapRunningRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrameLoop(_human.running.down, frame, frameRate: _frameRateRunning);
    case Direction.DownRight:
      return getFrameLoop(_human.running.downRight, frame, frameRate: _frameRateRunning);
    case Direction.Right:
      return getFrameLoop(_human.running.right, frame, frameRate: _frameRateRunning);
    case Direction.UpRight:
      return getFrameLoop(_human.running.upRight, frame, frameRate: _frameRateRunning);
    case Direction.Up:
      return getFrameLoop(_human.running.up, frame, frameRate: _frameRateRunning);
    case Direction.UpLeft:
      return getFrameLoop(_human.running.upLeft, frame, frameRate: _frameRateRunning);
    case Direction.Left:
      return getFrameLoop(_human.running.left, frame, frameRate: _frameRateRunning);
    case Direction.DownLeft:
      return getFrameLoop(_human.running.downLeft, frame, frameRate: _frameRateRunning);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapIdleRect(Direction direction) {
  switch (direction) {
    case Direction.Up:
      return _human.idle.up;
    case Direction.UpRight:
      return _human.idle.upRight;
    case Direction.Right:
      return _human.idle.right;
    case Direction.DownRight:
      return _human.idle.downRight;
    case Direction.Down:
      return _human.idle.down;
    case Direction.DownLeft:
      return _human.idle.downLeft;
    case Direction.Left:
      return _human.idle.left;
    case Direction.UpLeft:
      return _human.idle.upLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapDeadRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Up:
      return getFrame(_human.dying.up, frame);
    case Direction.UpRight:
      return getFrame(_human.dying.upRight, frame);
    case Direction.Right:
      return getFrame(_human.dying.right, frame);
    case Direction.DownRight:
      return getFrame(_human.dying.downRight, frame);
    case Direction.Down:
      return getFrame(_human.dying.down, frame);
    case Direction.DownLeft:
      return getFrame(_human.dying.downLeft, frame);
    case Direction.Left:
      return getFrame(_human.dying.left, frame);
    case Direction.UpLeft:
      return getFrame(_human.dying.upLeft, frame);
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect _mapAimingRect(Direction direction) {
  switch (direction) {
    case Direction.Up:
      return _aimingUp;
    case Direction.UpRight:
      return _aimingUpRight;
    case Direction.Right:
      return _aimingRight;
    case Direction.DownRight:
      return _aimingDownRight;
    case Direction.Down:
      return _aimingDown;
    case Direction.DownLeft:
      return _aimingDownLeft;
    case Direction.Left:
      return _aimingLeft;
    case Direction.UpLeft:
      return _aimingUpLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect _mapFiringRect(Weapon weapon, Direction direction, int frame) {
  return _mapFiringShotgunRect(direction, frame);
}

Rect _mapFiringShotgunRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrame(_human.firingShotgun.down, frame);
    case Direction.DownRight:
      return getFrame(_human.firingShotgun.downRight, frame);
    case Direction.Right:
      return getFrame(_human.firingShotgun.right, frame);
    case Direction.UpRight:
      return getFrame(_human.firingShotgun.upRight, frame);
    case Direction.Up:
      return getFrame(_human.firingShotgun.up, frame);
    case Direction.UpLeft:
      return getFrame(_human.firingShotgun.upLeft, frame);
    case Direction.Left:
      return getFrame(_human.firingShotgun.left, frame);
    case Direction.DownLeft:
      return getFrame(_human.firingShotgun.downLeft, frame);
  }
  throw Exception("could not get firing frame from direction");
}

Rect _mapStrikingRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Up:
      return getFrameLoop(_strikingUp, frame);
    case Direction.UpRight:
      return getFrameLoop(_strikingUpRight, frame);
    case Direction.Right:
      return getFrameLoop(_strikingRight, frame);
    case Direction.DownRight:
      return getFrameLoop(_strikingDownRight, frame);
    case Direction.Down:
      return getFrameLoop(_strikingDown, frame);
    case Direction.DownLeft:
      return getFrameLoop(_strikingDownLeft, frame);
    case Direction.Left:
      return getFrameLoop(_strikingLeft, frame);
    case Direction.UpLeft:
      return getFrameLoop(_strikingUpLeft, frame);
  }
  throw Exception("could not get firing frame from direction");
}
