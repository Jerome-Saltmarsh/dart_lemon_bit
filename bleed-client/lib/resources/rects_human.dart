import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';

import '../common.dart';
import '../keys.dart';
import 'rects_utils.dart';

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
List<Rect> _runningDown = _frames([63, 64, 65, 64]);

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

Rect getHumanWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_walkingUp, character);
    case directionUpRight:
      return getFrameLoop(_walkingDownLeft, character);
    case directionRight:
      return getFrameLoop(_walkingLeft, character);
    case directionDownRight:
      return getFrameLoop(_walkingUpLeft, character);
    case directionDown:
      return getFrameLoop(_walkingUp, character);
    case directionDownLeft:
      return getFrameLoop(_walkingDownLeft, character);
    case directionLeft:
      return getFrameLoop(_walkingLeft, character);
    case directionUpLeft:
      return getFrameLoop(_walkingUpLeft, character);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanReloadingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_reloadingUp, character);
    case directionUpRight:
      return getFrameLoop(_reloadingUpRight, character);
    case directionRight:
      return getFrameLoop(_reloadingRight, character);
    case directionDownRight:
      return getFrameLoop(_reloadingDownRight, character);
    case directionDown:
      return getFrameLoop(_reloadingDown, character);
    case directionDownLeft:
      return getFrameLoop(_reloadingDownLeft, character);
    case directionLeft:
      return getFrameLoop(_reloadingLeft, character);
    case directionUpLeft:
      return getFrameLoop(_reloadingUpLeft, character);
  }
  throw Exception("Could not get character reloading sprite rect");
}

Rect getHumanRunningRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(_runningUp, character);
    case directionUpRight:
      return getFrameLoop(_runningUpRight, character);
    case directionRight:
      return getFrameLoop(_runningRight, character);
    case directionDownRight:
      return getFrameLoop(_runningDownRight, character);
    case directionDown:
      return getFrameLoop(_runningDown, character);
    case directionDownLeft:
      return getFrameLoop(_runningDownLeft, character);
    case directionLeft:
      return getFrameLoop(_runningLeft, character);
    case directionUpLeft:
      return getFrameLoop(_runningUpLeft, character);
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanIdleRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _idleUp;
    case directionUpRight:
      return _idleUpRight;
    case directionRight:
      return _idleRight;
    case directionDownRight:
      return _idleDownRight;
    case directionDown:
      return _idleDown;
    case directionDownLeft:
      return _idleDownLeft;
    case directionLeft:
      return _idleLeft;
    case directionUpLeft:
      return _idleUpLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanDeadRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _deadDown;
    case directionUpRight:
      return _deadUpRight;
    case directionRight:
      return _deadRight;
    case directionDownRight:
      return _deadDownRight;
    case directionDown:
      return _deadDown;
    case directionDownLeft:
      return _deadUpRight;
    case directionLeft:
      return _deadRight;
    case directionUpLeft:
      return _deadDownRight;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect getHumanAimRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _aimingUp;
    case directionUpRight:
      return _aimingUpRight;
    case directionRight:
      return _aimingRight;
    case directionDownRight:
      return _aimingDownRight;
    case directionDown:
      return _aimingDown;
    case directionDownLeft:
      return _aimingDownLeft;
    case directionLeft:
      return _aimingLeft;
    case directionUpLeft:
      return _aimingUpLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect getCharacterSpriteRect(dynamic character) {
  switch (character[stateIndex]) {
    case characterStateIdle:
      return getHumanIdleRect(character);
    case characterStateWalking:
      return getHumanWalkingRect(character);
    case characterStateDead:
      return getHumanDeadRect(character);
    case characterStateAiming:
      return getHumanAimRect(character);
    case characterStateFiring:
      return getHumanFiringRect(character);
    case characterStateStriking:
      return getHumanStrikingRect(character);
    case characterStateRunning:
      return getHumanRunningRect(character);
    case characterStateReloading:
      return getHumanReloadingRect(character);
    case characterStateChangingWeapon:
      return getHumanReloadingRect(character);
  }
  throw Exception("Could not get character sprite rect");
}

Rect getHumanFiringRect(dynamic character) {
  switch (character[weapon]) {
    case Weapon.Shotgun:
      return getRectShotgunFiring(character);
    default:
      return getHandgunFiringRect(character);
  }
}

Rect getHandgunFiringRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrame(_firingRifleUp, character);
    case directionUpRight:
      return getFrame(_firingRifleUpRight, character);
    case directionRight:
      return getFrame(_firingRifleRight, character);
    case directionDownRight:
      return getFrame(_firingRifleDownRight, character);
    case directionDown:
      return getFrame(_firingRifleDown, character);
    case directionDownLeft:
      return getFrame(_firingRifleDownLeft, character);
    case directionLeft:
      return getFrame(_firingRifleLeft, character);
    case directionUpLeft:
      return getFrame(_firingRifleUpLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}

Rect getRectShotgunFiring(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrame(_firingShotgunUp, character);
    case directionUpRight:
      return getFrame(_firingShotgunUpRight, character);
    case directionRight:
      return getFrame(_firingShotgunRight, character);
    case directionDownRight:
      return getFrame(_firingShotgunDownRight, character);
    case directionDown:
      return getFrame(_firingShotgunDown, character);
    case directionDownLeft:
      return getFrame(_firingShotgunDownLeft, character);
    case directionLeft:
      return getFrame(_firingShotgunLeft, character);
    case directionUpLeft:
      return getFrame(_firingShotgunUpLeft, character);
  }
  throw Exception("could not get firing frame from direction");
}

Rect getHumanStrikingRect(character) {
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
