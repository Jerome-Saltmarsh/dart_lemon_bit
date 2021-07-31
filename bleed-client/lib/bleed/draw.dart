import 'dart:math';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'keys.dart';
import 'resources.dart';
import 'state.dart';
import 'utils.dart';

void drawCharacter(dynamic character) {
  int totalFrames = 1;
  int startFrame = 0;
  int direction = getDirection(character);

  switch (character[state]) {
    case characterStateIdle:
      startFrame = getStartFrameIdle(direction);
      break;
    case characterStateWalking:
      totalFrames = 3;
      startFrame = getStartFrameWalking(direction);
      break;
    case characterStateDead:
      startFrame = getStartFrameDead(direction);
      break;
    case characterStateAiming:
      startFrame = getStartFrameAiming(direction);
      break;
    case characterStateFiring:
      startFrame = getStartFrameFiring(direction);
      break;
  }

  int spriteFrame = (drawFrame % totalFrames) + startFrame;
  int frameCount = 36;

  drawSprite(spriteTemplate, frameCount, spriteFrame, character[posX],
      character[posY]);

  // drawCharacterCircle(
  //     character, character[keyCharacterId] == id ? Colors.blue : Colors.red);

  // drawText(character[keyPlayerName], posX(character),
  //     posY(character), Colors.white);
}

int getStartFrameWalking(int direction) {
  switch (direction) {
    case directionUp:
      return 13;
    case directionUpRight:
      return 4;
    case directionRight:
      return 7;
    case directionDownRight:
      return 10;
    case directionDown:
      return 13;
    case directionDownLeft:
      return 4;
    case directionLeft:
      return 7;
    case directionUpLeft:
      return 10;
  }
  return 13;
}

int getStartFrameIdle(int direction) {
  switch (direction) {
    case directionUp:
      return 3;
    case directionUpRight:
      return 0;
    case directionRight:
      return 1;
    case directionDownRight:
      return 2;
    case directionDown:
      return 3;
    case directionDownLeft:
      return 0;
    case directionLeft:
      return 1;
    case directionUpLeft:
      return 2;
  }
  return 3;
}

int getStartFrameDead(int direction) {
  switch (direction) {
    case directionUp:
      return 19;
    case directionUpRight:
      return 16;
    case directionRight:
      return 17;
    case directionDownRight:
      return 19;
    case directionDown:
      return 19;
    case directionDownLeft:
      return 16;
    case directionLeft:
      return 17;
    case directionUpLeft:
      return 19;
  }
  return 19;
}

int getStartFrameAiming(int direction) {
  switch (direction) {
    case directionUp:
      return 23;
    case directionUpRight:
      return 24;
    case directionRight:
      return 25;
    case directionDownRight:
      return 26;
    case directionDown:
      return 27;
    case directionDownLeft:
      return 20;
    case directionLeft:
      return 21;
    case directionUpLeft:
      return 22;
  }
  return 23;
}

int getStartFrameFiring(int direction) {
  switch (direction) {
    case directionUp:
      return 31;
    case directionUpRight:
      return 32;
    case directionRight:
      return 33;
    case directionDownRight:
      return 34;
    case directionDown:
      return 35;
    case directionDownLeft:
      return 28;
    case directionLeft:
      return 29;
    case directionUpLeft:
      return 30;
  }
  return 31;
}

void drawCharacterCircle(dynamic value, Color color) {
  drawCircle(value[posX], value[posY], characterRadius, color);
}

void drawCharacters() {
  if (spriteTemplate == null) return;
  players.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  players.where(isDead).forEach((drawCharacter));
  players.where(isAlive).forEach((drawCharacter));
  npcs.sort((a, b) => a[posY] > b[posY] ? 1 : -1);
  npcs.where(isDead).forEach((drawCharacter));
  npcs.where(isAlive).forEach((drawCharacter));
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

  double d = 250;
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 0));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 1));
  drawGrassTile(d + (sizeH * 1), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 0), d + (sizeH * 3));

  drawGrassTile(d + (sizeH * 4), d + (sizeH * 1));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 1), d + (sizeH * 4));

  drawGrassTile(d + (sizeH * 5), d + (sizeH * 2));
  drawGrassTile(d + (sizeH * 4), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 4));
  drawGrassTile(d + (sizeH * 2), d + (sizeH * 5));

  drawGrassTile(d + (sizeH * 6), d + (sizeH * 3));
  drawGrassTile(d + (sizeH * 5), d + (sizeH * 4));
  drawGrassTile(d + (sizeH * 4), d + (sizeH * 5));
  drawGrassTile(d + (sizeH * 3), d + (sizeH * 6));
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
