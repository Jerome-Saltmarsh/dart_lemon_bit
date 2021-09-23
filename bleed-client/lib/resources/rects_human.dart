import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';

import '../common.dart';
import '../keys.dart';
import 'rects_utils.dart';

const int humanSpriteFrameWidth = 36;
const int humanSpriteFrameHeight = 35;
const double halfHumanSpriteFrameWidth = humanSpriteFrameWidth * 0.5;
const double halfHumanSpriteFrameHeight = humanSpriteFrameHeight * 0.5;

Rect rectHumanIdleDownLeft = _getHumanSpriteRect(0);
Rect rectHumanIdleLeft = _getHumanSpriteRect(1);
Rect rectHumanIdleUpLeft = _getHumanSpriteRect(2);
Rect rectHumanIdleUp = _getHumanSpriteRect(3);
Rect rectHumanIdleUpRight = rectHumanIdleDownLeft;
Rect rectHumanIdleRight = rectHumanIdleLeft;
Rect rectHumanIdleDownRight = rectHumanIdleUpLeft;
Rect rectHumanIdleDown = rectHumanIdleUp;

Rect rectHumanRunningDownLeft1 = _frame(53);
Rect rectHumanRunningDownLeft2 = _frame(54);
Rect rectHumanRunningDownLeft3 = _frame(55);

Rect rectHumanRunningLeft1 = _frame(56);
Rect rectHumanRunningLeft2 = _frame(57);
Rect rectHumanRunningLeft3 = _frame(58);

Rect rectHumanRunningUpLeft1 = _frame(59);
Rect rectHumanRunningUpLeft2 = _frame(60);
Rect rectHumanRunningUpLeft3 = _frame(61);

Rect rectHumanRunningUp1 = _frame(62);
Rect rectHumanRunningUp2 = _frame(63);
Rect rectHumanRunningUp3 = _frame(64);

Rect rectHumanRunningUpRight1 = _frame(65);
Rect rectHumanRunningUpRight2 = _frame(66);
Rect rectHumanRunningUpRight3 = _frame(67);

Rect rectHumanRunningRight1 = _frame(68);
Rect rectHumanRunningRight2 = _frame(69);
Rect rectHumanRunningRight3 = _frame(70);

Rect rectHumanRunningDownRight1 = _frame(71);
Rect rectHumanRunningDownRight2 = _frame(72);
Rect rectHumanRunningDownRight3 = _frame(73);

Rect rectHumanRunningDown1 = rectHumanRunningUp1;
Rect rectHumanRunningDown2 = rectHumanRunningUp2;
Rect rectHumanRunningDown3 = rectHumanRunningUp3;

Rect rectHumanDeadUpRight = _getHumanSpriteRect(16);
Rect rectHumanDeadRight = _getHumanSpriteRect(17);
Rect rectHumanDeadDownRight = _getHumanSpriteRect(18);
Rect rectHumanDeadDown = _getHumanSpriteRect(19);

Rect rectHumanAimingDownLeft = _getHumanSpriteRect(20);
Rect rectHumanAimingLeft = _getHumanSpriteRect(21);
Rect rectHumanAimingUpLeft = _getHumanSpriteRect(22);
Rect rectHumanAimingUp = _getHumanSpriteRect(23);
Rect rectHumanAimingUpRight = _getHumanSpriteRect(24);
Rect rectHumanAimingRight = _getHumanSpriteRect(25);
Rect rectHumanAimingDownRight = _getHumanSpriteRect(26);
Rect rectHumanAimingDown = _getHumanSpriteRect(27);

Rect rectHumanFiringDownLeft = _getHumanSpriteRect(28);
Rect rectHumanFiringLeft = _getHumanSpriteRect(29);
Rect rectHumanFiringUpLeft = _getHumanSpriteRect(30);
Rect rectHumanFiringUp = _getHumanSpriteRect(31);
Rect rectHumanFiringUpRight = _getHumanSpriteRect(32);
Rect rectHumanFiringRight = _getHumanSpriteRect(33);
Rect rectHumanFiringDownRight = _getHumanSpriteRect(34);
Rect rectHumanFiringDown = _getHumanSpriteRect(35);

Rect rectHumanStrikingDownLeft = _getHumanSpriteRect(36);
Rect rectHumanStrikingLeft = _getHumanSpriteRect(37);
Rect rectHumanStrikingUpLeft = _getHumanSpriteRect(38);
Rect rectHumanStrikingUp = _getHumanSpriteRect(39);
Rect rectHumanStrikingUpRight = _getHumanSpriteRect(40);
Rect rectHumanStrikingRight = _getHumanSpriteRect(41);
Rect rectHumanStrikingDownRight = _getHumanSpriteRect(42);
Rect rectHumanStrikingDown = _getHumanSpriteRect(43);

Rect rectHumanBlastDownLeft = _getHumanSpriteRect(44);
Rect rectHumanBlastLeft = _getHumanSpriteRect(45);
Rect rectHumanBlastUpLeft = _getHumanSpriteRect(46);
Rect rectHumanBlastUp = _getHumanSpriteRect(47);
Rect rectHumanBlastUpRight = _getHumanSpriteRect(48);
Rect rectHumanBlastRight = _getHumanSpriteRect(49);
Rect rectHumanBlastDownRight = _getHumanSpriteRect(50);
Rect rectHumanBlastDown = _getHumanSpriteRect(51);

List<Rect> rectHumanFiringDownLeftFrames = [
  rectHumanBlastDownLeft,
  rectHumanFiringDownLeft,
  rectHumanAimingDownLeft,
];

List<Rect> rectHumanFiringLeftFrames = [
  rectHumanBlastLeft,
  rectHumanFiringLeft,
  rectHumanAimingLeft,
];

List<Rect> rectHumanFiringUpLeftFrames = [
  rectHumanBlastUpLeft,
  rectHumanFiringUpLeft,
  rectHumanAimingUpLeft,
];

List<Rect> rectHumanFiringUpFrames = [
  rectHumanBlastUp,
  rectHumanFiringUp,
  rectHumanAimingUp,
];

List<Rect> rectHumanFiringUpRightFrames = [
  rectHumanBlastUpRight,
  rectHumanFiringUpRight,
  rectHumanAimingUpRight,
];

List<Rect> rectHumanFiringRightFrames = [
  rectHumanBlastRight,
  rectHumanFiringRight,
  rectHumanAimingRight,
];

List<Rect> rectHumanFiringDownRightFrames = [
  rectHumanBlastDownRight,
  rectHumanFiringDownRight,
  rectHumanAimingDownRight,
];

List<Rect> rectHumanFiringDownFrames = [
  rectHumanBlastDown,
  rectHumanFiringDown,
  rectHumanAimingDown,
];

// Shotgun frames

List<Rect> rectFiringShotgunDownLeftFrames = [
  rectHumanBlastDownLeft,
  rectHumanFiringDownLeft,
  rectHumanAimingDownLeft,
];

List<Rect> rectFiringShotgunLeftFrames = [
  rectHumanBlastLeft,
  rectHumanFiringLeft,
  rectHumanAimingLeft,
];

List<Rect> rectFiringShotgunUpLeftFrames = [
  rectHumanBlastUpLeft,
  rectHumanFiringUpLeft,
  rectHumanAimingUpLeft,
];

List<Rect> rectFiringShotgunUpFrames = [
  rectHumanBlastUp,
  rectHumanFiringUp,
  rectHumanAimingUp,
];

List<Rect> rectFiringShotgunUpRightFrames = [
  rectHumanBlastUpRight,
  rectHumanFiringUpRight,
  rectHumanAimingUpRight,
];

List<Rect> rectFiringShotgunRightFrames = [
  rectHumanBlastRight,
  rectHumanFiringRight,
  rectHumanAimingRight,
];

List<Rect> rectFiringShotgunDownRightFrames = [
  rectHumanBlastDownRight,
  rectHumanFiringDownRight,
  rectHumanAimingDownRight,
];

List<Rect> rectFiringShotgunDownFrames = [
  rectHumanBlastDown,
  rectHumanFiringDown,
  rectHumanAimingDown,
];

// End Shotgun frames

List<Rect> rectHumanWalkingDownLeftFrames = [
  _getHumanSpriteRect(4),
  _getHumanSpriteRect(5),
  _getHumanSpriteRect(6),
  _getHumanSpriteRect(5),
];

List<Rect> rectHumanWalkingLeftFrames = [
  _getHumanSpriteRect(7),
  _getHumanSpriteRect(8),
  _getHumanSpriteRect(9),
  _getHumanSpriteRect(8),
];

List<Rect> rectHumanWalkingUpLeftFrames = [
  _getHumanSpriteRect(10),
  _getHumanSpriteRect(11),
  _getHumanSpriteRect(12),
  _getHumanSpriteRect(11),
];

List<Rect> rectHumanWalkingUpFrames = [
  _getHumanSpriteRect(13),
  _getHumanSpriteRect(14),
  _getHumanSpriteRect(15),
  _getHumanSpriteRect(14),
];

List<Rect> _reloadingDownLeft = _frames([74, 74, 74, 75, 75, 75]);
List<Rect> _reloadingLeft = _frames([76, 76, 76, 77, 77, 77]);
List<Rect> _reloadingUpLeft = _frames([78, 78, 78, 79, 79, 79]);
List<Rect> _reloadingUp = _frames([80, 80, 80, 81, 81, 81]);
List<Rect> _reloadingUpRight = _frames([82, 82, 82, 83, 83, 83]);
List<Rect> _reloadingRight = _frames([84, 84, 84, 85, 85, 85]);
List<Rect> _reloadingDownRight = _frames([86, 86, 86, 87, 87, 87]);
List<Rect> _reloadingDown = _frames([88, 88, 88, 89, 89, 89]);

List<Rect> _runningDownLeft = _frames([61, 62, 63, 62]);
List<Rect> _runningLeft = _frames([64, 65, 66, 65]);
List<Rect> _runningUpLeft = _frames([67, 68, 69, 68]);
List<Rect> _runningUp = _frames([70, 71, 72, 71]);
List<Rect> _runningUpRight = _frames([73, 74, 75, 74]);
List<Rect> _runningRight = _frames([76, 77, 78, 77]);
List<Rect> _runningDownRight = _frames([79, 80, 81, 80]);
List<Rect> _runningDown = _frames([70, 71, 72, 71]);

List<Rect> _strikingDownLeft = _frames([37, 38]);
List<Rect> _strikingLeft = _frames([39, 40]);
List<Rect> _strikingUpLeft = _frames([41, 42]);
List<Rect> _strikingUp = _frames([43, 44]);
List<Rect> _strikingUpRight = _frames([45, 46]);
List<Rect> _strikingRight = _frames([47, 48]);
List<Rect> _strikingDownRight = _frames([49, 50]);
List<Rect> _strikingDown = _frames([51, 52]);


Rect _frame(int index) {
  return _getHumanSpriteRect(index - 1);
}

Rect _getHumanSpriteRect(int index) {
  return Rect.fromLTWH((index * humanSpriteFrameWidth).toDouble(), 0.0,
      humanSpriteFrameWidth.toDouble(), humanSpriteFrameHeight.toDouble());
}

List<Rect> _frames(List<int> indexes) {
  List<Rect> rects = [];
  for (int i in indexes) {
    rects.add(_getHumanSpriteRect(i - 1));
  }
  return rects;
}

Rect getHumanWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(rectHumanWalkingUpFrames, character);
    case directionUpRight:
      return getFrameLoop(rectHumanWalkingDownLeftFrames, character);
    case directionRight:
      return getFrameLoop(rectHumanWalkingLeftFrames, character);
    case directionDownRight:
      return getFrameLoop(rectHumanWalkingUpLeftFrames, character);
    case directionDown:
      return getFrameLoop(rectHumanWalkingUpFrames, character);
    case directionDownLeft:
      return getFrameLoop(rectHumanWalkingDownLeftFrames, character);
    case directionLeft:
      return getFrameLoop(rectHumanWalkingLeftFrames, character);
    case directionUpLeft:
      return getFrameLoop(rectHumanWalkingUpLeftFrames, character);
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
      return rectHumanIdleUp;
    case directionUpRight:
      return rectHumanIdleUpRight;
    case directionRight:
      return rectHumanIdleRight;
    case directionDownRight:
      return rectHumanIdleDownRight;
    case directionDown:
      return rectHumanIdleDown;
    case directionDownLeft:
      return rectHumanIdleDownLeft;
    case directionLeft:
      return rectHumanIdleLeft;
    case directionUpLeft:
      return rectHumanIdleUpLeft;
  }
  throw Exception("Could not get character walking sprite rect");
}

Rect getHumanDeadRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanDeadDown;
    case directionUpRight:
      return rectHumanDeadUpRight;
    case directionRight:
      return rectHumanDeadRight;
    case directionDownRight:
      return rectHumanDeadDownRight;
    case directionDown:
      return rectHumanDeadDown;
    case directionDownLeft:
      return rectHumanDeadUpRight;
    case directionLeft:
      return rectHumanDeadRight;
    case directionUpLeft:
      return rectHumanDeadDownRight;
  }
  throw Exception("Could not get character dead sprite rect");
}

Rect getHumanAimRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanAimingUp;
    case directionUpRight:
      return rectHumanAimingUpRight;
    case directionRight:
      return rectHumanAimingRight;
    case directionDownRight:
      return rectHumanAimingDownRight;
    case directionDown:
      return rectHumanAimingDown;
    case directionDownLeft:
      return rectHumanAimingDownLeft;
    case directionLeft:
      return rectHumanAimingLeft;
    case directionUpLeft:
      return rectHumanAimingUpLeft;
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
      return getFrame(rectHumanFiringUpFrames, character);
    case directionUpRight:
      return getFrame(rectHumanFiringUpRightFrames, character);
    case directionRight:
      return getFrame(rectHumanFiringRightFrames, character);
    case directionDownRight:
      return getFrame(rectHumanFiringDownRightFrames, character);
    case directionDown:
      return getFrame(rectHumanFiringDownFrames, character);
    case directionDownLeft:
      return getFrame(rectHumanFiringDownLeftFrames, character);
    case directionLeft:
      return getFrame(rectHumanFiringLeftFrames, character);
    case directionUpLeft:
      return getFrame(rectHumanFiringUpLeftFrames, character);
  }
  throw Exception("could not get firing frame from direction");
}

Rect getRectShotgunFiring(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrame(rectFiringShotgunUpFrames, character);
    case directionUpRight:
      return getFrame(rectFiringShotgunUpRightFrames, character);
    case directionRight:
      return getFrame(rectFiringShotgunRightFrames, character);
    case directionDownRight:
      return getFrame(rectFiringShotgunDownRightFrames, character);
    case directionDown:
      return getFrame(rectFiringShotgunDownFrames, character);
    case directionDownLeft:
      return getFrame(rectFiringShotgunDownLeftFrames, character);
    case directionLeft:
      return getFrame(rectFiringShotgunLeftFrames, character);
    case directionUpLeft:
      return getFrame(rectFiringShotgunUpLeftFrames, character);
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
