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
  drawList(npcs, npcsTransformMemory, npcsRectMemory);
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
  drawList(players, playersTransformMemory, playersRectMemory);
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
  }
  throw Exception("Could not get character sprite rect");
}

Rect getHumanFiringRect(character) {
  switch (character[direction]) {
    case directionUp:
      return rectHumanFiringUp;
    case directionUpRight:
      return rectHumanFiringUpRight;
    case directionRight:
      return rectHumanFiringRight;
    case directionDownRight:
      return rectHumanFiringDownRight;
    case directionDown:
      return rectHumanFiringDown;
    case directionDownLeft:
      return rectHumanFiringDownLeft;
    case directionLeft:
      return rectHumanFiringLeft;
    case directionUpLeft:
      return rectHumanFiringUpLeft;
  }
  throw Exception("could not get firing frame from direction");
}

Rect _getFrame(List<Rect> frames) {
  return frames[drawFrame % frames.length];
}

const int humanSpriteFrames = 36;
const int humanSpriteImageWidth = 1728;
const double humanSpriteFrameWidth = humanSpriteImageWidth / humanSpriteFrames;
const double humanSpriteFrameHeight = 72;

Rect rectHumanIdleDownLeft = getHumanSprite(0);
Rect rectHumanIdleLeft = getHumanSprite(1);
Rect rectHumanIdleUpLeft = getHumanSprite(2);
Rect rectHumanIdleUp = getHumanSprite(3);
Rect rectHumanIdleUpRight = rectHumanIdleDownLeft;
Rect rectHumanIdleRight = rectHumanIdleLeft;
Rect rectHumanIdleDownRight = rectHumanIdleUpLeft;
Rect rectHumanIdleDown = rectHumanIdleUp;

Rect rectHumanDeadUpRight = getHumanSprite(16);
Rect rectHumanDeadRight = getHumanSprite(17);
Rect rectHumanDeadDownRight = getHumanSprite(18);
Rect rectHumanDeadDown = getHumanSprite(19);

Rect rectHumanAimingDownLeft = getHumanSprite(20);
Rect rectHumanAimingLeft = getHumanSprite(21);
Rect rectHumanAimingUpLeft = getHumanSprite(22);
Rect rectHumanAimingUp = getHumanSprite(23);
Rect rectHumanAimingUpRight = getHumanSprite(24);
Rect rectHumanAimingRight = getHumanSprite(25);
Rect rectHumanAimingDownRight = getHumanSprite(26);
Rect rectHumanAimingDown = getHumanSprite(27);

Rect rectHumanFiringDownLeft = getHumanSprite(28);
Rect rectHumanFiringLeft = getHumanSprite(29);
Rect rectHumanFiringUpLeft = getHumanSprite(30);
Rect rectHumanFiringUp = getHumanSprite(31);
Rect rectHumanFiringUpRight = getHumanSprite(32);
Rect rectHumanFiringRight = getHumanSprite(33);
Rect rectHumanFiringDownRight = getHumanSprite(34);
Rect rectHumanFiringDown = getHumanSprite(35);


List<Rect> rectHumanWalkingDownLeftFrames = [
  getHumanSprite(4),
  getHumanSprite(5),
  getHumanSprite(6),
];

List<Rect> rectHumanWalkingLeftFrames = [
  getHumanSprite(7),
  getHumanSprite(8),
  getHumanSprite(9),
];

List<Rect> rectHumanWalkingUpLeftFrames = [
  getHumanSprite(10),
  getHumanSprite(11),
  getHumanSprite(12),
];

List<Rect> rectHumanWalkingUpFrames = [
  getHumanSprite(13),
  getHumanSprite(14),
  getHumanSprite(15)
];

Rect getHumanSprite(int index) {
  return Rect.fromLTWH(index * humanSpriteFrameWidth, 0.0,
      humanSpriteFrameWidth, humanSpriteFrameHeight);
}

RSTransform getCharacterTransform(dynamic character) {
  return RSTransform.fromComponents(
    rotation: 0.0,
    scale: 1.0,
    anchorX: 5.0,
    anchorY: 5.0,
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
