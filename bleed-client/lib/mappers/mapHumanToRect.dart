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
      return _mapDeadRect(direction);
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

// abstraction
const int _humanSpriteFrameWidth = 36;
const int _humanSpriteFrameHeight = 35;
const double halfHumanSpriteFrameWidth = _humanSpriteFrameWidth * 0.5;
const double halfHumanSpriteFrameHeight = _humanSpriteFrameHeight * 0.5;

// TODO state belongs in state directory

_Human _human = _Human();

class _Human {
  final _Idle idle = _Idle();
  final _Walking walking = _Walking();
  final _Running running = _Running();
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


Rect _deadUpRight = _frame(17);
Rect _deadRight = _frame(18);
Rect _deadDownRight = _frame(19);
Rect _deadDown = _frame(20);

Rect _aimingDownLeft = _frame(21);
Rect _aimingLeft = _frame(23);
Rect _aimingUpLeft = _frame(25);
Rect _aimingUp = _frame(27);
Rect _aimingUpRight = _frame(29);
Rect _aimingRight = _frame(31);
Rect _aimingDownRight = _frame(33);
Rect _aimingDown = _frame(35);

List<Rect> _firingRifleDownLeft = _frames([22, 21]);
List<Rect> _firingRifleLeft = _frames([24, 23]);
List<Rect> _firingRifleUpLeft = _frames([26, 25]);
List<Rect> _firingRifleUp = _frames([28, 27]);
List<Rect> _firingRifleUpRight = _frames([30, 29]);
List<Rect> _firingRifleRight = _frames([32, 31]);
List<Rect> _firingRifleDownRight = _frames([34, 33]);
List<Rect> _firingRifleDown = _frames([36, 35]);

List<Rect> _firingShotgunDownLeft  = _frames([22, 21]);
List<Rect> _firingShotgunLeft = _frames([24, 23]);
List<Rect> _firingShotgunUpLeft = _frames([26, 25]);
List<Rect> _firingShotgunUp = _frames([28, 27]);
List<Rect> _firingShotgunUpRight = _frames([30, 29]);
List<Rect> _firingShotgunRight = _frames([32, 31]);
List<Rect> _firingShotgunDownRight = _frames([34, 33]);
List<Rect> _firingShotgunDown = _frames([36, 35]);

List<Rect> _reloadingDownLeft = _frames([74, 74, 74, 75, 75, 75]);
List<Rect> _reloadingLeft = _frames([76, 76, 76, 77, 77, 77]);
List<Rect> _reloadingUpLeft = _frames([78, 78, 78, 79, 79, 79]);
List<Rect> _reloadingUp = _frames([80, 80, 80, 81, 81, 81]);
List<Rect> _reloadingUpRight = _frames([82, 82, 82, 83, 83, 83]);
List<Rect> _reloadingRight = _frames([84, 84, 84, 85, 85, 85]);
List<Rect> _reloadingDownRight = _frames([86, 86, 86, 87, 87, 87]);
List<Rect> _reloadingDown = _frames([88, 88, 88, 89, 89, 89]);

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
    case Direction.Up:
      return getFrameLoop(_reloadingUp, frame);
    case Direction.UpRight:
      return getFrameLoop(_reloadingUpRight, frame);
    case Direction.Right:
      return getFrameLoop(_reloadingRight, frame);
    case Direction.DownRight:
      return getFrameLoop(_reloadingDownRight, frame);
    case Direction.Down:
      return getFrameLoop(_reloadingDown, frame);
    case Direction.DownLeft:
      return getFrameLoop(_reloadingDownLeft, frame);
    case Direction.Left:
      return getFrameLoop(_reloadingLeft, frame);
    case Direction.UpLeft:
      return getFrameLoop(_reloadingUpLeft, frame);
  }
  throw Exception("Could not get character reloading sprite rect");
}

Rect _mapRunningRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrameLoop(_human.running.down, frame);
    case Direction.DownRight:
      return getFrameLoop(_human.running.downRight, frame);
    case Direction.Right:
      return getFrameLoop(_human.running.right, frame);
    case Direction.UpRight:
      return getFrameLoop(_human.running.upRight, frame);
    case Direction.Up:
      return getFrameLoop(_human.running.up, frame);
    case Direction.UpLeft:
      return getFrameLoop(_human.running.upLeft, frame);
    case Direction.Left:
      return getFrameLoop(_human.running.left, frame);
    case Direction.DownLeft:
      return getFrameLoop(_human.running.downLeft, frame);
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

Rect _mapDeadRect(Direction direction) {
  switch (direction) {
    case Direction.Up:
      return _deadDown;
    case Direction.UpRight:
      return _deadUpRight;
    case Direction.Right:
      return _deadRight;
    case Direction.DownRight:
      return _deadDownRight;
    case Direction.Down:
      return _deadDown;
    case Direction.DownLeft:
      return _deadUpRight;
    case Direction.Left:
      return _deadRight;
    case Direction.UpLeft:
      return _deadDownRight;
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
  switch (weapon) {
    case Weapon.Shotgun:
      return _mapFiringShotgunRect(direction, frame);
    default:
      return _mapFiringRifleRect(direction, frame);
  }
}

Rect _mapFiringRifleRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Up:
      return getFrame(_firingRifleUp, frame);
    case Direction.UpRight:
      return getFrame(_firingRifleUpRight, frame);
    case Direction.Right:
      return getFrame(_firingRifleRight, frame);
    case Direction.DownRight:
      return getFrame(_firingRifleDownRight, frame);
    case Direction.Down:
      return getFrame(_firingRifleDown, frame);
    case Direction.DownLeft:
      return getFrame(_firingRifleDownLeft, frame);
    case Direction.Left:
      return getFrame(_firingRifleLeft, frame);
    case Direction.UpLeft:
      return getFrame(_firingRifleUpLeft, frame);
  }
  throw Exception("could not get firing frame from direction");
}

Rect _mapFiringShotgunRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Up:
      return getFrame(_firingShotgunUp, frame);
    case Direction.UpRight:
      return getFrame(_firingShotgunUpRight, frame);
    case Direction.Right:
      return getFrame(_firingShotgunRight, frame);
    case Direction.DownRight:
      return getFrame(_firingShotgunDownRight, frame);
    case Direction.Down:
      return getFrame(_firingShotgunDown, frame);
    case Direction.DownLeft:
      return getFrame(_firingShotgunDownLeft, frame);
    case Direction.Left:
      return getFrame(_firingShotgunLeft, frame);
    case Direction.UpLeft:
      return getFrame(_firingShotgunUpLeft, frame);
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
