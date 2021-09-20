import 'dart:ui';

import 'package:bleed_client/common/Weapons.dart';

import '../common.dart';
import '../keys.dart';
import 'rects_utils.dart';

const int humanSpriteFrameWidth = 36;
const int humanSpriteFrameHeight = 35;
const double halfHumanSpriteFrameWidth = humanSpriteFrameWidth * 0.5;
const double halfHumanSpriteFrameHeight = humanSpriteFrameHeight * 0.5;

Rect rectHumanIdleDownLeft = getHumanSpriteRect(0);
Rect rectHumanIdleLeft = getHumanSpriteRect(1);
Rect rectHumanIdleUpLeft = getHumanSpriteRect(2);
Rect rectHumanIdleUp = getHumanSpriteRect(3);
Rect rectHumanIdleUpRight = rectHumanIdleDownLeft;
Rect rectHumanIdleRight = rectHumanIdleLeft;
Rect rectHumanIdleDownRight = rectHumanIdleUpLeft;
Rect rectHumanIdleDown = rectHumanIdleUp;

Rect rectHumanRunningDownLeft1 = _humanRect(53);
Rect rectHumanRunningDownLeft2 = _humanRect(54);
Rect rectHumanRunningDownLeft3 = _humanRect(55);

Rect rectHumanRunningLeft1 = _humanRect(56);
Rect rectHumanRunningLeft2 = _humanRect(57);
Rect rectHumanRunningLeft3 = _humanRect(58);

Rect rectHumanRunningUpLeft1 = _humanRect(59);
Rect rectHumanRunningUpLeft2 = _humanRect(60);
Rect rectHumanRunningUpLeft3 = _humanRect(61);

Rect rectHumanRunningUp1 = _humanRect(62);
Rect rectHumanRunningUp2 = _humanRect(63);
Rect rectHumanRunningUp3 = _humanRect(64);

Rect rectHumanRunningUpRight1 = _humanRect(65);
Rect rectHumanRunningUpRight2 = _humanRect(66);
Rect rectHumanRunningUpRight3 = _humanRect(67);

Rect rectHumanRunningRight1 = _humanRect(68);
Rect rectHumanRunningRight2 = _humanRect(69);
Rect rectHumanRunningRight3 = _humanRect(70);

Rect rectHumanRunningDownRight1 = _humanRect(71);
Rect rectHumanRunningDownRight2 = _humanRect(72);
Rect rectHumanRunningDownRight3 = _humanRect(73);

Rect rectHumanRunningDown1 = rectHumanRunningUp1;
Rect rectHumanRunningDown2 = rectHumanRunningUp2;
Rect rectHumanRunningDown3 = rectHumanRunningUp3;

Rect rectHumanDeadUpRight = getHumanSpriteRect(16);
Rect rectHumanDeadRight = getHumanSpriteRect(17);
Rect rectHumanDeadDownRight = getHumanSpriteRect(18);
Rect rectHumanDeadDown = getHumanSpriteRect(19);

Rect rectHumanAimingDownLeft = getHumanSpriteRect(20);
Rect rectHumanAimingLeft = getHumanSpriteRect(21);
Rect rectHumanAimingUpLeft = getHumanSpriteRect(22);
Rect rectHumanAimingUp = getHumanSpriteRect(23);
Rect rectHumanAimingUpRight = getHumanSpriteRect(24);
Rect rectHumanAimingRight = getHumanSpriteRect(25);
Rect rectHumanAimingDownRight = getHumanSpriteRect(26);
Rect rectHumanAimingDown = getHumanSpriteRect(27);

Rect rectHumanFiringDownLeft = getHumanSpriteRect(28);
Rect rectHumanFiringLeft = getHumanSpriteRect(29);
Rect rectHumanFiringUpLeft = getHumanSpriteRect(30);
Rect rectHumanFiringUp = getHumanSpriteRect(31);
Rect rectHumanFiringUpRight = getHumanSpriteRect(32);
Rect rectHumanFiringRight = getHumanSpriteRect(33);
Rect rectHumanFiringDownRight = getHumanSpriteRect(34);
Rect rectHumanFiringDown = getHumanSpriteRect(35);

Rect rectHumanStrikingDownLeft = getHumanSpriteRect(36);
Rect rectHumanStrikingLeft = getHumanSpriteRect(37);
Rect rectHumanStrikingUpLeft = getHumanSpriteRect(38);
Rect rectHumanStrikingUp = getHumanSpriteRect(39);
Rect rectHumanStrikingUpRight = getHumanSpriteRect(40);
Rect rectHumanStrikingRight = getHumanSpriteRect(41);
Rect rectHumanStrikingDownRight = getHumanSpriteRect(42);
Rect rectHumanStrikingDown = getHumanSpriteRect(43);

Rect rectHumanBlastDownLeft = getHumanSpriteRect(44);
Rect rectHumanBlastLeft = getHumanSpriteRect(45);
Rect rectHumanBlastUpLeft = getHumanSpriteRect(46);
Rect rectHumanBlastUp = getHumanSpriteRect(47);
Rect rectHumanBlastUpRight = getHumanSpriteRect(48);
Rect rectHumanBlastRight = getHumanSpriteRect(49);
Rect rectHumanBlastDownRight = getHumanSpriteRect(50);
Rect rectHumanBlastDown = getHumanSpriteRect(51);

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
  getHumanSpriteRect(4),
  getHumanSpriteRect(5),
  getHumanSpriteRect(6),
  getHumanSpriteRect(5),
];

List<Rect> rectHumanWalkingLeftFrames = [
  getHumanSpriteRect(7),
  getHumanSpriteRect(8),
  getHumanSpriteRect(9),
  getHumanSpriteRect(8),
];

List<Rect> rectHumanWalkingUpLeftFrames = [
  getHumanSpriteRect(10),
  getHumanSpriteRect(11),
  getHumanSpriteRect(12),
  getHumanSpriteRect(11),
];

List<Rect> rectHumanWalkingUpFrames = [
  getHumanSpriteRect(13),
  getHumanSpriteRect(14),
  getHumanSpriteRect(15),
  getHumanSpriteRect(14),
];

// Reloading

List<Rect> rectsHumanReloadingDownLeft = humanRects([74, 74, 74, 75, 75, 75]);
List<Rect> rectsHumanReloadingLeft = humanRects([76, 76, 76, 77, 77, 77]);
List<Rect> rectsHumanReloadingUpLeft = humanRects([78, 78, 78, 79, 79, 79]);
List<Rect> rectsHumanReloadingUp = humanRects([80, 80, 80, 81, 81, 81]);
List<Rect> rectsHumanReloadingUpRight = humanRects([82, 82, 82, 83, 83, 83]);
List<Rect> rectsHumanReloadingRight = humanRects([84, 84, 84, 85, 85, 85]);
List<Rect> rectsHumanReloadingDownRight = humanRects([86, 86, 86, 87, 87, 87]);
List<Rect> rectsHumanReloadingDown = humanRects([88, 88, 88, 89, 89, 89]);


List<Rect> rectHumanRunningDownLeftFrames = [
  rectHumanRunningDownLeft1,
  rectHumanRunningDownLeft2,
  rectHumanRunningDownLeft3,
  rectHumanRunningDownLeft2,
];

List<Rect> rectHumanRunningLeftFrames = [
  rectHumanRunningLeft1,
  rectHumanRunningLeft2,
  rectHumanRunningLeft3,
  rectHumanRunningLeft2,
];

List<Rect> rectHumanRunningUpLeftFrames = [
  rectHumanRunningUpLeft1,
  rectHumanRunningUpLeft2,
  rectHumanRunningUpLeft3,
  rectHumanRunningUpLeft2,
];

List<Rect> rectHumanRunningUpFrames = [
  rectHumanRunningUp1,
  rectHumanRunningUp2,
  rectHumanRunningUp3,
  rectHumanRunningUp2,
];

List<Rect> rectHumanRunningUpRightFrames = [
  rectHumanRunningUpRight1,
  rectHumanRunningUpRight2,
  rectHumanRunningUpRight3,
  rectHumanRunningUpRight2,
];

List<Rect> rectHumanRunningRightFrames = [
  rectHumanRunningRight1,
  rectHumanRunningRight2,
  rectHumanRunningRight3,
  rectHumanRunningRight2,
];

List<Rect> rectHumanRunningDownRightFrames = [
  rectHumanRunningDownRight1,
  rectHumanRunningDownRight2,
  rectHumanRunningDownRight3,
  rectHumanRunningDownRight2,
];

List<Rect> rectHumanRunningDownFrames = [
  rectHumanRunningDown1,
  rectHumanRunningDown2,
  rectHumanRunningDown3,
  rectHumanRunningDown2,
];

List<Rect> humanStrikingDownLeftFrames = [
  rectHumanStrikingDownLeft,
  rectHumanIdleDownLeft
];

List<Rect> humanStrikingLeftFrames = [rectHumanStrikingLeft, rectHumanIdleLeft];

List<Rect> humanStrikingUpLeftFrames = [
  rectHumanStrikingUpLeft,
  rectHumanIdleUpLeft
];

List<Rect> humanStrikingUpFrames = [rectHumanStrikingUp, rectHumanIdleUp];

List<Rect> humanStrikingUpRightFrames = [
  rectHumanStrikingUpRight,
  rectHumanIdleUpRight
];

List<Rect> humanStrikingRightFrames = [
  rectHumanStrikingRight,
  rectHumanIdleRight
];

List<Rect> humanStrikingDownRightFrames = [
  rectHumanStrikingDownRight,
  rectHumanIdleDownRight
];

List<int> characterRunningUp = [12, 51, 55, 51];
List<Rect> humanStrikingDownFrames = [rectHumanStrikingDown, rectHumanIdleDown];

Rect getHumanSpriteRect(int index) {
  return Rect.fromLTWH((index * humanSpriteFrameWidth).toDouble(), 0.0,
      humanSpriteFrameWidth.toDouble(), humanSpriteFrameHeight.toDouble());
}

Rect _humanRect(int index) {
  return getHumanSpriteRect(index - 1);
}

List<Rect> humanRects(List<int> indexes) {
  List<Rect> rects = [];
  for (int i in indexes) {
    rects.add(getHumanSpriteRect(i - 1));
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
      return getFrameLoop(rectsHumanReloadingUp, character);
    case directionUpRight:
      return getFrameLoop(rectsHumanReloadingUpRight, character);
    case directionRight:
      return getFrameLoop(rectsHumanReloadingRight, character);
    case directionDownRight:
      return getFrameLoop(rectsHumanReloadingDownRight, character);
    case directionDown:
      return getFrameLoop(rectsHumanReloadingDown, character);
    case directionDownLeft:
      return getFrameLoop(rectsHumanReloadingDownLeft, character);
    case directionLeft:
      return getFrameLoop(rectsHumanReloadingLeft, character);
    case directionUpLeft:
      return getFrameLoop(rectsHumanReloadingUpLeft, character);
  }
  throw Exception("Could not get character reloading sprite rect");
}

Rect getHumanRunningRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return getFrameLoop(rectHumanRunningUpFrames, character);
    case directionUpRight:
      return getFrameLoop(rectHumanRunningUpRightFrames, character);
    case directionRight:
      return getFrameLoop(rectHumanRunningRightFrames, character);
    case directionDownRight:
      return getFrameLoop(rectHumanRunningDownRightFrames, character);
    case directionDown:
      return getFrameLoop(rectHumanRunningDownFrames, character);
    case directionDownLeft:
      return getFrameLoop(rectHumanRunningDownLeftFrames, character);
    case directionLeft:
      return getFrameLoop(rectHumanRunningLeftFrames, character);
    case directionUpLeft:
      return getFrameLoop(rectHumanRunningUpLeftFrames, character);
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
      return getFrameLoop(humanStrikingUpFrames, character);
    case directionUpRight:
      return getFrameLoop(humanStrikingUpRightFrames, character);
    case directionRight:
      return getFrameLoop(humanStrikingRightFrames, character);
    case directionDownRight:
      return getFrameLoop(humanStrikingDownRightFrames, character);
    case directionDown:
      return getFrameLoop(humanStrikingDownFrames, character);
    case directionDownLeft:
      return getFrameLoop(humanStrikingDownLeftFrames, character);
    case directionLeft:
      return getFrameLoop(humanStrikingLeftFrames, character);
    case directionUpLeft:
      return getFrameLoop(humanStrikingUpLeftFrames, character);
  }
  throw Exception("could not get firing frame from direction");
}
