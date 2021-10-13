import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';

import '../common.dart';
import '../keys.dart';
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
      return _mapStrikingRect(direction);
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

Rect _idleDownLeft = _frame(1);
Rect _idleLeft = _frame(2);
Rect _idleUpLeft = _frame(3);
Rect _idleUp = _frame(4);
Rect _idleUpRight = _frame(1);
Rect _idleRight = _frame(2);
Rect _idleDownRight = _frame(3);
Rect _idleDown = _frame(4);

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

List<Rect> _walkingDownLeft = _frames([5, 6, 7, 6]);
List<Rect> _walkingLeft = _frames([8, 9, 10, 9]);
List<Rect> _walkingUpLeft = _frames([11, 12, 13, 12]);
List<Rect> _walkingUp = _frames([14, 15, 16, 15]);

List<Rect> _runningDownLeft = _frames([53, 54, 55, 54]);
List<Rect> _runningLeft = _frames([56, 57, 58, 57]);
List<Rect> _runningUpLeft = _frames([59, 60, 61, 60]);
List<Rect> _runningUp = _frames([62, 63, 64, 63]);
List<Rect> _runningUpRight = _frames([65, 66, 67, 66]);
List<Rect> _runningRight = _frames([68, 69, 70, 69]);
List<Rect> _runningDownRight = _frames([71, 72, 73, 72]);
List<Rect> _runningDown = _frames([62, 63, 64, 63]);

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
  return Rect.fromLTWH((index * _humanSpriteFrameWidth).toDouble(), 0.0,
      _humanSpriteFrameWidth.toDouble(), _humanSpriteFrameHeight.toDouble());
}

Rect _mapWalkingRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Up:
      return getFrameLoop(_walkingUp, frame);
    case Direction.UpRight:
      return getFrameLoop(_walkingDownLeft, frame);
    case Direction.Right:
      return getFrameLoop(_walkingLeft, frame);
    case Direction.DownRight:
      return getFrameLoop(_walkingUpLeft, frame);
    case Direction.Down:
      return getFrameLoop(_walkingUp, frame);
    case Direction.DownLeft:
      return getFrameLoop(_walkingDownLeft, frame);
    case Direction.Left:
      return getFrameLoop(_walkingLeft, frame);
    case Direction.UpLeft:
      return getFrameLoop(_walkingUpLeft, frame);
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
    case Direction.Up:
      return getFrameLoop(_runningUp, frame);
    case Direction.UpRight:
      return getFrameLoop(_runningUpRight, frame);
    case Direction.Right:
      return getFrameLoop(_runningRight, frame);
    case Direction.DownRight:
      return getFrameLoop(_runningDownRight, frame);
    case Direction.Down:
      return getFrameLoop(_runningDown, frame);
    case Direction.DownLeft:
      return getFrameLoop(_runningDownLeft, frame);
    case Direction.Left:
      return getFrameLoop(_runningLeft, frame);
    case Direction.UpLeft:
      return getFrameLoop(_runningUpLeft, frame);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect _mapIdleRect(Direction direction) {
  switch (direction) {
    case Direction.Up:
      return _idleUp;
    case Direction.UpRight:
      return _idleUpRight;
    case Direction.Right:
      return _idleRight;
    case Direction.DownRight:
      return _idleDownRight;
    case Direction.Down:
      return _idleDown;
    case Direction.DownLeft:
      return _idleDownLeft;
    case Direction.Left:
      return _idleLeft;
    case Direction.UpLeft:
      return _idleUpLeft;
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

Rect _mapStrikingRect(character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_strikingUp, character);
    case directionUpRight:
      return getFrameLoop(_strikingUpRight, character);
    case directionRight:
      return getFrameLoop(_strikingRight, character);
    case directionDownRight:
      return getFrameLoop(_strikingDownRight, character);
    case directionDown:
      return getFrameLoop(_strikingDown, character);
    case directionDownLeft:
      return getFrameLoop(_strikingDownLeft, character);
    case directionLeft:
      return getFrameLoop(_strikingLeft, character);
    case directionUpLeft:
      return getFrameLoop(_strikingUpLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}
