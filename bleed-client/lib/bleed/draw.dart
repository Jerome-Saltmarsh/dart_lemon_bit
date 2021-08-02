import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/engine_draw.dart';
import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'keys.dart';
import 'resources.dart';
import 'state.dart';
import 'utils.dart';


void drawCharacterCircle(dynamic value, Color color) {
  if (value == null) return;
  drawCircle(value[posX], value[posY], characterRadius, color);
}

void drawCharacters() {
  if (imageHuman == null) return;
  // players.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  // players.where(isDead).forEach((drawCharacter));
  // players.where(isAlive).forEach((drawCharacter));
  // npcs.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  // npcs.where(isDead).forEach((drawCharacter));
  // npcs.where(isAlive).forEach((drawCharacter));
  drawPlayers();
  drawNpcs();
}

void drawNpcs() {
  drawList(npcs, npcsTransforms, npcsRects);
}

void drawCharacterList(List<dynamic> characters) {
  globalCanvas.drawAtlas(
      imageHuman,
      characters.map(getCharacterTransform).toList(),
      characters.map(getCharacterSpriteRect).toList(),
      null,
      null,
      null,
      globalPaint);
}

void drawPlayers() {
  drawList(players, playersTransforms, playersRects);
}

void drawList(List<dynamic> values, List<RSTransform> transforms, List<Rect> rects) {
  for (int i = 0; i < values.length; i++) {
    if (i >= transforms.length) {
      transforms.add(getCharacterTransform(values[i]));
    } else {
      transforms[i] = getCharacterTransform(values[i]);
    }
    if (i >= rects.length) {
      rects.add(getCharacterSpriteRect(values[i]));
    } else {
      rects[i] = getCharacterSpriteRect(values[i]);
    }
  }
  while(transforms.length > values.length){
    transforms.removeLast();
  }
  while(rects.length > values.length){
    rects.removeLast();
  }
  globalCanvas.drawAtlas(
      imageHuman,
      transforms,
      rects,
      null,
      null,
      null,
      globalPaint);
}

Rect getHumanWalkingRect(dynamic character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectHumanWalkingUpFrames);
    case directionUpRight:
      return _getFrame(rectHumanWalkingDownLeftFrames);
    case directionRight:
      return _getFrame(rectHumanWalkingLeftFrames);
    case directionDownRight:
      return _getFrame(rectHumanWalkingUpLeftFrames);
    case directionDown:
      return _getFrame(rectHumanWalkingUpFrames);
    case directionDownLeft:
      return _getFrame(rectHumanWalkingDownLeftFrames);
    case directionLeft:
      return _getFrame(rectHumanWalkingLeftFrames);
    case directionUpLeft:
      return _getFrame(rectHumanWalkingUpLeftFrames);
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
  switch (character[state]) {
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
  }
  throw Exception("Could not get character sprite rect");
}

Rect getHumanFiringRect(character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(rectHumanFiringUpFrames);
    case directionUpRight:
      return _getFrame(rectHumanFiringUpRightFrames);
    case directionRight:
      return _getFrame(rectHumanFiringRightFrames);
    case directionDownRight:
      return _getFrame(rectHumanFiringDownRightFrames);
    case directionDown:
      return _getFrame(rectHumanFiringDownFrames);
    case directionDownLeft:
      return _getFrame(rectHumanFiringDownLeftFrames);
    case directionLeft:
      return _getFrame(rectHumanFiringLeftFrames);
    case directionUpLeft:
      return _getFrame(rectHumanFiringUpLeftFrames);
  }
  throw Exception("could not get firing frame from direction");
}

Rect getHumanStrikingRect(character) {
  switch (character[direction]) {
    case directionUp:
      return _getFrame(humanStrikingUpFrames);
    case directionUpRight:
      return _getFrame(humanStrikingUpRightFrames);
    case directionRight:
      return _getFrame(humanStrikingRightFrames);
    case directionDownRight:
      return _getFrame(humanStrikingDownRightFrames);
    case directionDown:
      return _getFrame(humanStrikingDownFrames);
    case directionDownLeft:
      return _getFrame(humanStrikingDownLeftFrames);
    case directionLeft:
      return _getFrame(humanStrikingLeftFrames);
    case directionUpLeft:
      return _getFrame(humanStrikingUpLeftFrames);
  }
  throw Exception("could not get firing frame from direction");
}

List<Rect> humanStrikingDownLeftFrames = [
  rectHumanStrikingDownLeft,
  rectHumanIdleDownLeft
];

List<Rect> humanStrikingLeftFrames = [
  rectHumanStrikingLeft,
  rectHumanIdleLeft
];

List<Rect> humanStrikingUpLeftFrames = [
  rectHumanStrikingUpLeft,
  rectHumanIdleUpLeft
];

List<Rect> humanStrikingUpFrames = [
  rectHumanStrikingUp,
  rectHumanIdleUp
];

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

List<Rect> humanStrikingDownFrames = [
  rectHumanStrikingDown,
  rectHumanIdleDown
];


Rect _getFrame(List<Rect> frames) {
  return frames[drawFrame % frames.length];
}

const int humanSpriteFrames = 52;
const int humanSpriteFrameWidth = 48;
const int humanSpriteFrameHeight = 72;
const int humanSpriteImageWidth = humanSpriteFrames * humanSpriteFrameWidth;
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


List<Rect> rectHumanWalkingDownLeftFrames = [
  getHumanSpriteRect(4),
  getHumanSpriteRect(5),
  getHumanSpriteRect(6),
];

List<Rect> rectHumanWalkingLeftFrames = [
  getHumanSpriteRect(7),
  getHumanSpriteRect(8),
  getHumanSpriteRect(9),
];

List<Rect> rectHumanWalkingUpLeftFrames = [
  getHumanSpriteRect(10),
  getHumanSpriteRect(11),
  getHumanSpriteRect(12),
];

List<Rect> rectHumanWalkingUpFrames = [
  getHumanSpriteRect(13),
  getHumanSpriteRect(14),
  getHumanSpriteRect(15)
];

Rect getHumanSpriteRect(int index) {
  return Rect.fromLTWH((index * humanSpriteFrameWidth).toDouble(), 0.0,
      humanSpriteFrameWidth.toDouble(), humanSpriteFrameHeight.toDouble());
}

RSTransform getCharacterTransform(dynamic character) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: halfHumanSpriteFrameWidth,
    anchorY: halfHumanSpriteFrameHeight,
    translateX: character[x] - cameraX,
    translateY: character[y] - cameraY,
  );
}

void drawCircleOutline(
    {int sides = 16, double radius, double x, double y, Color color}) {
  double r = (pi * 2) / sides;
  List<Offset> points = [];
  Offset z = Offset(x, y);
  setColor(color);
  for (int i = 0; i <= sides; i++) {
    double a1 = i * r;
    points.add(Offset(cos(a1) * radius - cameraX, sin(a1) * radius - cameraY));
  }
  for (int i = 0; i < points.length - 1; i++) {
    canvas.drawLine(points[i] + z, points[i + 1] + z, globalPaint);
  }
}

void drawBullets() {
  bullets.forEach((bullet) {
    drawCircle(bullet[x], bullet[y], 2, white);
  });
}

void drawMouse() {
  if (!mouseAvailable) return;
  drawCircleOutline(
      radius: 5, x: mousePosX + cameraX, y: mousePosY + cameraY, color: white);
}

void drawTiles() {
  if (tileGrass01 == null) return;

  double size = tileGrass01.width * 1.0;
  double sizeH = size * 0.5;

  int tiles = 5;

  for (int x = 0; x < tiles; x++) {
    drawGrassTile((sizeH * (5 - x)), (sizeH * x));
  }

  return;

}

void drawGrassTile(double x, double y) {
  drawImage(tileGrass01, x, y);
}

void setColor(Color value) {
  globalPaint.color = value;
}

void drawBulletRange() {
  if (!playerAssigned) return;
  dynamic player = getPlayerCharacter();
  drawCircleOutline(
      radius: bulletRange, x: player[posX], y: player[posY], color: white);
}
